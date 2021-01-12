package com.reactnativesecurekeypad;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.Log;
import com.yhdb.solution.ysecukeypad.library.common.CommonUtil;

import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

public class HttpUtil {
    private String cookies = null;
    public HttpsURLConnection conHttps;	// https 연결
    public HttpURLConnection conHttp;	// http 연결

    @SuppressLint("DefaultLocale")
    public String httpRequest(URL url, String cookie, JSONObject lParam, Context mContext, String userToken) {
        String strReturn = "";
        this.cookies = cookie;
        String hashPackageName = CommonUtil.getHashPackageName(mContext);

        if("https".equals(url.getProtocol().toLowerCase())) {
            strReturn = this.httpsConnect(url, lParam, hashPackageName, userToken);
        } else {
            strReturn = this.httpConnect(url, lParam, hashPackageName, userToken);
        }

        return strReturn;
    }

    private String httpsConnect(URL url, JSONObject lParam, String hashPackageName, String userToken) {
        String value = "";
        try {
            System.setProperty("http.keepAlive", "true");
            SSLContext sc = null;

            try {
                sc = SSLContext.getInstance("SSL");
            } catch (NoSuchAlgorithmException ex) {
                sc = SSLContext.getInstance("TLS");
            }

            if(sc != null) {
                sc.init(null, new TrustManager[] { new TrivialTrustManager() }, new SecureRandom());
            } else {
                return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
            }

            HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
            HttpsURLConnection.setDefaultHostnameVerifier(new PassiveHostnameVerifier());

            System.setProperty("http.keepAlive", "false");
            conHttps = (HttpsURLConnection)url.openConnection();
            conHttps.setUseCaches(false);
            conHttps.setConnectTimeout(120 * 1000);
            conHttps.setReadTimeout(120 * 1000);
//            conHttps.setRequestProperty("Content-Length", Integer.toString(lParam.getBytes().length));
            conHttps.setRequestProperty("Connection", "Keep-Alive");
            conHttps.setRequestMethod("POST");
            conHttps.setRequestProperty("Host", url.getHost());
            conHttps.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conHttps.setRequestProperty("X-Application", "yhdatabase");
            conHttps.setRequestProperty("yskpd_license_info", hashPackageName);
            conHttps.setRequestProperty("Authorization", "Bearer " + userToken);
            if(cookies != null) {
                conHttps.setRequestProperty("Cookie", cookies);
            }
            conHttps.setDoOutput(true);
            conHttps.setDoInput(true);
            conHttps.connect();

            DataOutputStream ostream = null;
            ostream = new DataOutputStream(conHttps.getOutputStream());
            ostream.writeBytes(lParam.toString());
            ostream.flush();
            ostream.close();

            InputStream instream = conHttps.getInputStream();

            if(conHttps.getResponseCode() == HttpsURLConnection.HTTP_OK) {
                String cookiesTmp = readHttpsCookies(conHttps);
                if(cookiesTmp != null) {
                    cookies = cookiesTmp;
                }

                BufferedReader reader = new BufferedReader(new InputStreamReader(instream));

                String line;
                while ((line = reader.readLine()) != null) {
                    value = value + line;
                }
            } else {
                value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
            }

            instream.close();
            conHttps.disconnect();
        } catch (NoSuchAlgorithmException e) {
            value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
        } catch (KeyManagementException e) {
            value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
        } catch (IOException e) {
            value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
        }

        return value;
    }

    public static String convertStreamToString(InputStream is) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder sb = new StringBuilder();

        String line = null;

        try {
            while ((line = reader.readLine()) != null) {
                sb.append(line + "\n");
            }
        } catch (IOException e1) {
            Log.d("HttpUtil", "IOException occurred");
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                Log.d("HttpUtil", "IOException occurred");
            }
        }

        return sb.toString();
    }

    @SuppressLint("DefaultLocale")
    protected String readHttpsCookies(HttpsURLConnection con) {
        StringBuilder cookieBuffer = null;
        String cookieField = null;
        String headerName = null;

        for(int i = 1; (headerName = con.getHeaderFieldKey(i)) != null; i++) {
            if(headerName.toLowerCase().equals("set-cookie")) {
                cookieField = con.getHeaderField(i);
                cookieField = cookieField.substring(0, cookieField.indexOf(";"));

                if(cookieBuffer != null) {
                    cookieBuffer.append(";");
                } else {
                    cookieBuffer = new StringBuilder();
                }
                cookieBuffer.append(cookieField);
            }
        }

        if(cookieBuffer != null) {
            return cookieBuffer.toString();
        } else {
            return null;
        }
    }

    @SuppressLint("DefaultLocale")
    protected String readHttpCookies(HttpURLConnection con) {
        StringBuilder cookieBuffer = null;
        String cookieField = null;
        String headerName = null;

        for(int i = 1; (headerName = con.getHeaderFieldKey(i)) != null; i++) {
            if(headerName.toLowerCase().equals("set-cookie")) {
                cookieField = con.getHeaderField(i);
                cookieField = cookieField.substring(0, cookieField.indexOf(";"));

                if(cookieBuffer != null) {
                    cookieBuffer.append(";");
                } else {
                    cookieBuffer = new StringBuilder();
                }
                cookieBuffer.append(cookieField);
            }
        }

        if(cookieBuffer != null) {
            return cookieBuffer.toString();
        } else {
            return null;
        }
    }

    private String httpConnect(URL url, JSONObject lParam, String hashPackageName, String userToken) {
        String value = "";
        String json = lParam.toString();
        try {
            System.setProperty("http.keepAlive", "false");

            conHttp = (HttpURLConnection)url.openConnection();
            conHttp.setUseCaches(false);
            conHttp.setConnectTimeout(120 * 1000);
            conHttp.setReadTimeout(120 * 1000);
            // conHttp.setRequestProperty("Content-Length", Integer.toString(lParam.getBytes().length));
            conHttp.setRequestProperty("Connection", "Keep-Alive");
            conHttp.setRequestMethod("POST");
            conHttp.setRequestProperty("Host", url.getHost());
            conHttp.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conHttp.setRequestProperty("X-Application", "yhdatabase");
            conHttp.setRequestProperty("yskpd_license_info", hashPackageName);
            conHttp.setRequestProperty("Authorization", "Bearer " + userToken);

            if(cookies != null) {
                conHttp.setRequestProperty("Cookie", cookies);
            }

            conHttp.setDoOutput(true);
            conHttp.setDoInput(true);
            conHttp.connect();

            DataOutputStream ostream = null;
            ostream = new DataOutputStream(conHttp.getOutputStream());
            ostream.writeBytes(json);
            ostream.flush();
            ostream.close();

            InputStream instream = conHttp.getInputStream();
            if(conHttp.getResponseCode() == HttpsURLConnection.HTTP_OK) {
                String cookiesTmp = readHttpCookies(conHttp);

                if(cookiesTmp != null) {
                    cookies = cookiesTmp;
                }

                BufferedReader reader = new BufferedReader(new InputStreamReader(instream));

                String line;
                while ((line = reader.readLine()) != null) {
                    value = value + line;
                }
            } else {
                value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
            }

            instream.close();
            conHttp.disconnect();
        } catch (IOException e) {
            value = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><result><result_code>0</result_code><msg>알 수 없는 오류가 발생하였습니다.</msg><result>";
        }

        return value;
    }
}

class PassiveHostnameVerifier implements HostnameVerifier {
    @Override
    public boolean verify(String hostname, SSLSession session) {
        return true;
    }
}

class TrivialTrustManager implements X509TrustManager {

    @Override
    public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
    }

    @Override
    public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
    }

    @Override
    public X509Certificate[] getAcceptedIssuers() {
        return null;
    }
}