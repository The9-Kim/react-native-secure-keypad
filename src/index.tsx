import { NativeModules } from 'react-native';

type SecureKeypadType = {
  multiply(a: number, b: number): Promise<number>;
};

const { SecureKeypad } = NativeModules;

export default SecureKeypad as SecureKeypadType;
