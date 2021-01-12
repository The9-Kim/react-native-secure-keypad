declare type SecureKeypadType = {
    show(url: string, maxLength: number, labelText: string): Promise<string>;
    request(url: string, inputHash: string, token: string): Promise<string>;
    getRequestHeader(): Promise<string>;
};
declare const _default: SecureKeypadType;
export default _default;
