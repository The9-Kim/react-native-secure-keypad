import { NativeModules } from 'react-native';

type SecureKeypadType = {
  showWithRequestUrl(url: string): Promise<string>;
  // initNumberPad(url: string): void;
};

const { SecureKeypad } = NativeModules;

export default SecureKeypad as SecureKeypadType;
