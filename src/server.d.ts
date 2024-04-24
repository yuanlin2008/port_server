export type Pid = string
export type CallTag = string
export type Payload = any

export function reply(pid: Pid, tag: CallTag, payload: Payload): void
export function cast(pid: Pid, payload: Payload): void
export function monitor(pid: Pid)

export type CallbackCall = (pid: Pid, tag: CallTag, payload: Payload) => void
export type CallbackCast = (pid: Pid, payload: Payload) => void
export type CallbackDown = (pid: Pid) => void

export function on(event: "call", callback: CallbackCall): void
export function on(event: "cast", callback: CallbackCast): void
export function on(event: "down", callback: CallbackDown): void

export function start(): void
