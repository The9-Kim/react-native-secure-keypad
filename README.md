# react-native-secure-keypad

secure keypad for react-native

## Installation

```sh
yarn add https://github.com/The9-Kim/react-native-secure-keypad
cd ios
pod install
```

아래 라이브러리를 ios Project > Link Binary With Libraries 에 추가한다.

YSecuKeypadSDK.framework
libz.tbd
AudioToolBox.framework

## Usage

```js
import SecureKeypad from "react-native-secure-keypad";

// ...
const inNeedNewHash = true; // or false
const result = await SecureKeypad.show(PATH.키패드해시요청, 6, '거래 승인번호 입력', isNeedNewHash);
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
