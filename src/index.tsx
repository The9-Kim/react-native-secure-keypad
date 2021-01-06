import { NativeModules } from 'react-native';

type SecureKeypadType = {
  showWithRequestUrl(url: string, maxLength: number, labelText: string): Promise<string>;
};

const { SecureKeypad } = NativeModules;

export default SecureKeypad as SecureKeypadType;
