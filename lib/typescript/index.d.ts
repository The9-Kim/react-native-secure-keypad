declare type SecureKeypadType = {
    show(url: string, maxLength: number, labelText: string): Promise<string>;
    saveTranPw(url: string, inputHash: string, kpdType: string): Promise<string>;
};
declare const _default: SecureKeypadType;
export default _default;
