import { Erlang, OtpErlangPid } from "erlang_js";

export type Pid = string;

export function create(erlPid: OtpErlangPid) {
  return erlPid.binary().toString();
}
