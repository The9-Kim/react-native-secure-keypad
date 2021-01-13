package com.reactnativesecurekeypad

import android.app.Activity
import android.content.Intent
import android.os.AsyncTask
import android.os.Bundle
import android.util.Log
import com.facebook.react.bridge.*
import com.yhdb.solution.ysecukeypad.library.common.CommonUtil
import com.yhdb.solution.ysecukeypad.library.keypad.RequestSecuKeypadHash
import com.yhdb.solution.ysecukeypad.library.keypad.YSecuKeypadNumberPadActivity
import org.json.JSONObject
import java.io.UnsupportedEncodingException
import java.net.MalformedURLException
import java.net.URL


class SecureKeypadModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val RUN_KEYPAD_REQUEST_CODE = 55765
    private val TAG_SECURE_KEYPAD = "SECURE_KEYPAD"
    private val TAG_FAILED = "SECURE_KEYPAD_FAILED"

    private var currentMethod = "activity"

    var strRequestUrl = ""

    var strHashUrl = ""
    var strKpdType = "11"
    var strMethod = "json"

    var strCookie = ""
    var strYskHash = ""
    var strYskHash1 = ""
    var strYskHash2 = ""

    private var mSecureKeypadPromise: Promise? = null
    private var mRequestPromise: Promise? = null

    private var mLabelText: String = "암호 입력"
    private var mMaxLength: Int = 6

    override fun getName(): String {
        return "SecureKeypad"
    }
    private val mActivityEventListener: ActivityEventListener = object : BaseActivityEventListener() {
        override fun onActivityResult(activity: Activity, requestCode: Int, resultCode: Int, intent: Intent?) {
            Log.d(TAG_SECURE_KEYPAD, "onActivityResult :: ${requestCode}, ${resultCode}, ${intent}")

            if (requestCode == RUN_KEYPAD_REQUEST_CODE) {
                if (mSecureKeypadPromise != null) {
                    if (resultCode == Activity.RESULT_OK) {
                        if (intent != null) {
                            val inputValue = intent.getExtras()!!.getString("inputValue")
                            val inputHash = intent.getExtras()!!.getString("inputHash")
                            val jsonResult = JSONObject()
                            val hashPackageName = CommonUtil.getHashPackageName(reactApplicationContext)

                            jsonResult.put("inputValue", inputValue)
                            jsonResult.put("inputHash", inputHash)
                            jsonResult.put("strCookie", strCookie)
                            jsonResult.put("hashPackageName", hashPackageName)


                            mSecureKeypadPromise?.let { promise ->
                                promise.resolve(jsonResult.toString())
                                mSecureKeypadPromise = null
                            }
                        }
                    } else if (resultCode == Activity.RESULT_CANCELED) {
                        if (intent != null) {
                            val code = intent.extras!!.getString("code")
                            val message = intent.extras!!.getString("message")
//                            Log.d(TAG_SECURE_KEYPAD, "onActivityResult :: $code, $message")
                            mSecureKeypadPromise?.let { promise ->
                                promise.reject(TAG_FAILED, "[$code] $message")
                                mSecureKeypadPromise = null
                            }
                        } else {
                            mSecureKeypadPromise?.let { promise ->
                                promise.reject(TAG_FAILED, "[9999] 실패")
                                mSecureKeypadPromise = null
                            }

                        }
                    }
                    mSecureKeypadPromise = null
                }
            }
        }
    }

    init {
//        Log.d(TAG_SECURE_KEYPAD, "addActivityEventListener")
        reactContext.addActivityEventListener(mActivityEventListener)
    }

    fun showKeypad() {
        val keypadIntent = Intent(reactApplicationContext, YSecuKeypadNumberPadActivity::class.java)
//        keypadIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        keypadIntent.putExtra("yskhash", strYskHash)
        keypadIntent.putExtra("maxLength", mMaxLength)
        keypadIntent.putExtra("isLandScape", false)
        keypadIntent.putExtra("labelText", mLabelText)
        reactApplicationContext.startActivityForResult(keypadIntent, RUN_KEYPAD_REQUEST_CODE, Bundle.EMPTY)
    }

    @ReactMethod
    fun getRequestHeader(promise: Promise) {
        val hashPackageName = CommonUtil.getHashPackageName(reactApplicationContext)
        val xApplication = "yhdatabase"
        val jsonObject = JSONObject()
        jsonObject.put("hashPackageName", hashPackageName);
        jsonObject.put("xApplication", xApplication);
        // Log.d(TAG_SECURE_KEYPAD, "jsonObject :: "+jsonObject.toString());
        promise.resolve(jsonObject.toString())
        // return jsonObject.toString()
    }

    @ReactMethod
    fun show(url: String, maxLength: Int, labelText: String, promise: Promise) {
        mSecureKeypadPromise = promise
        mMaxLength = when {
            maxLength>0 -> {
                maxLength
            }
            else -> {
                6
            }
        }

        mLabelText = labelText

        // if (strHashUrl.isBlank() || strMethod.isBlank() || strKpdType.isBlank()) {
            strHashUrl = url
            GetRequestHashDataTask().execute(strHashUrl, strMethod, strKpdType)
        // }

//        Log.d(TAG_SECURE_KEYPAD, "${strHashUrl}, ${strMethod}, ${strKpdType}")
        // if (strYskHash.isNotBlank()) {
        //     showKeypad();
        // }

    }

    @ReactMethod
    fun request(url: String, bodyJsonStr: String, token: String, promise: Promise) {
        mRequestPromise = promise
        strRequestUrl = url

        if (strRequestUrl.isNotBlank()) {
           SendDataTask().execute(strKpdType, bodyJsonStr, token, strRequestUrl)
        }
    }

    /**
     * 가상키패드에서 사용할 해쉬값 요청
     */
    inner class GetRequestHashDataTask : AsyncTask<String?, Void?, Map<String?, String?>>() {
        override fun onPostExecute(result: Map<String?, String?>) {
            super.onPostExecute(result)
            Log.d(TAG_SECURE_KEYPAD, result.entries.toTypedArray().contentToString())
            val code = result["code"]
            val strMessage = result["message"]

            if (code != null && "" != code && "0000" == code) {
                val strCode = result["code"]
                if ("0000" == strCode) {
                    strCookie = result["cookie"].toString()
                    strYskHash = result["yskhash"].toString()
                    strYskHash1 = result["yskhash1"].toString()
                    strYskHash2 = result["yskhash2"].toString()
                    if (strYskHash.isNotBlank()) {
                        showKeypad();
                    }
                } else {
                    mSecureKeypadPromise?.let { promise ->
                        promise.reject(TAG_FAILED, "[$code] $strMessage")
                        mSecureKeypadPromise = null
                    }
                }
            } else {
                mSecureKeypadPromise?.let { promise ->
                    promise.reject(TAG_FAILED, "[$code] $strMessage")
                    mSecureKeypadPromise = null
                }
            }
        }

        override fun doInBackground(vararg params: String?): Map<String?, String?> {
            val hashUrl = params[0]
            val method = params[1]
            val kpdType = params[2]
            val reqKeypadHash = RequestSecuKeypadHash(hashUrl, method, kpdType, reactApplicationContext)

            return reqKeypadHash.startReqKeypadHash() as Map<String?, String?>
        }
    }

    /**
     * 복호화 요청
     */
    inner class SendDataTask : AsyncTask<String?, Void?, String?>() {
        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)
            val resultJsonObject = JSONObject(result)
            val code = resultJsonObject.getString("code")
            if (code == "0000") {
                mRequestPromise?.let { promise ->
                    promise.resolve(result)
                    mRequestPromise = null
                }
            } else {
                mRequestPromise?.let { promise ->
                    promise.reject(code, resultJsonObject.getString("message"))
                    mRequestPromise = null
                }
            }

            
//            Log.d(TAG_SECURE_KEYPAD, "SendDataTask" + result)
//            if (parseResult != null) {
//                val code = parseResult["code"]
//                if ("0000" == code) {
//                    val decodeStr = parseResult["decodeStr"]
//                    tvDecodeValue1.setText(decodeStr)
//                    val decodeStr2 = parseResult["decodeStr2"]
//                    tvDecodeValue2.setText(decodeStr2)
//                } else {
//                    val message = parseResult["message"]
//                    val alertDlg = AlertDialog.Builder(this@MultiNumberPadViewActivity)
//                    alertDlg.setTitle("오류")
//                    alertDlg.setMessage(message)
//                    alertDlg.setCancelable(false)
//                    alertDlg.setNegativeButton("확인", null)
//                    alertDlg.show()
//                }
//            } else {
//                val alertDlg = AlertDialog.Builder(this@MultiNumberPadViewActivity)
//                alertDlg.setTitle("오류")
//                alertDlg.setMessage("복호화 결과 파싱에 실패하였습니다.")
//                alertDlg.setCancelable(false)
//                alertDlg.setNegativeButton("확인", null)
//                alertDlg.show()
//            }
        }

        override fun doInBackground(vararg params: String?): String? {
            // SendDataTask().execute(strKpdType, bodyJsonStr, "", "", token, strRequestUrl)

            val kpdType = params[0]
            val bodyJsonStr = params[1]
            val userToken = params[2]
            val url = params[3]

            val jsonObject = JSONObject(bodyJsonStr)
            var resultData: String? = null
            try {
                val decodeUrl = URL(url)

                jsonObject.put("kpdType", kpdType);
                // jsonObject.put("membCd", membCd);
                // jsonObject.put("appCd", appCd);

                val httpUtil = HttpUtil()
                resultData = httpUtil.httpRequest(decodeUrl, strCookie, jsonObject, reactApplicationContext, userToken)
            } catch (e: MalformedURLException) {
                mRequestPromise?.let { promise ->
                    promise.reject(TAG_FAILED, e.localizedMessage)
                    mRequestPromise = null
                }
            } catch (e: UnsupportedEncodingException) {
                mRequestPromise?.let { promise ->
                    promise.reject(TAG_FAILED, e.localizedMessage)
                    mRequestPromise = null
                }
            }

            return resultData
        }
    }

}
