import { NativeModules } from 'react-native';

type SecureKeypadType = {
  show(url: string, maxLength: number, labelText: string): Promise<string>;
  saveTranPw(url: string, inputHash: string, kpdType: string, membCd:string, appCd:string): Promise<string>;
};

const { SecureKeypad } = NativeModules;

export default SecureKeypad as SecureKeypadType;
