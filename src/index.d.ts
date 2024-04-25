export type Pid = string
export type CallTag = string
export type Payload = any

export type CallbackCall = (pid: Pid, tag: CallTag, payload: Payload) => void
export type CallbackCast = (pid: Pid, payload: Payload) => void
export type CallbackDown = (pid: Pid) => void

export function reply(pid: Pid, tag: CallTag, payload: Payload): void
export function cast(pid: Pid, msg: string, payload: Payload): void
export function monitor(pid: Pid, callback: CallbackDown): void

export function onCall(msg: string, callback: CallbackCall): void
export function onCast(msg: string, callback: CallbackCast): void

export function start(): void
