import { NativeModules } from 'react-native';

type SecureKeypadType = {
  show(url: string, maxLength: number, labelText: string, isNeedNewHash: boolean): Promise<string>;
  request(url: string, inputHash: string, token: string): Promise<string>;
  getRequestHeader(): Promise<string>;
};

const { SecureKeypad } = NativeModules;

export default SecureKeypad as SecureKeypadType;
