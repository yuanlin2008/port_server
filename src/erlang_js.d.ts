declare module "erlang_js" {
  interface OtpErlangBase {
    binary(): Buffer;
    toString(): string;
  }
  interface OtpErlangAtom extends OtpErlangBase {}
  interface OtpErlangAtomLarge extends OtpErlangBase {
    value: string;
  }
  interface OtpErlangBinary extends OtpErlangBase {}
  interface OtpErlangPid extends OtpErlangBase {}
  interface OtpErlangReference extends OtpErlangBase {}
  type OtpErlangTerm = number | string | OtpErlangAtom | OtpErlangAtomLarge;
  export const Erlang: {
    binary_to_term(
      data: Buffer,
      callback: (r: undefined | Error, term: OtpErlangTerm) => void
    ): void;
  };
}
