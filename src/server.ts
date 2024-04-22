import fs from "fs"
import { REPL_MODE_SLOPPY } from "repl"

export type Pid = string
export type CallTag = string

export interface Handler {
  handleCall(pid: Pid, tag: CallTag, name: string, payload: any): void
  handleCast(pid: Pid, name: string, payload: any): void
  handleDown(pid: Pid): void
}

export interface API {
  cast(pid: Pid, payload: any): void
  reply(pid: Pid, tag: CallTag, payload: any): void
  monitor(pid: Pid): void
}

export function run(handler: Handler): API {
  const input = fs.createReadStream("", { fd: 3 })
  const output = fs.createWriteStream("", { fd: 4 })

  let frameLength: undefined | number
  input.on("readable", () => {
    // Read frame length.
    if (frameLength === undefined) {
      const buf = input.read(4)
      if (buf !== null) {
        frameLength = buf.readUInt32BE(0)
      }
    }
    // Read frame
    if (frameLength !== undefined) {
      const frame = input.read(frameLength)
      if (frame !== null) {
        handleFrame(frame, handler)
      }
    }
  })

  function cast(pid: Pid, payload: any) {}
  function reply(pid: Pid, tag: CallTag, payload: any) {}
  function monitor(pid: Pid) {}
  return { cast, reply, monitor }
}

function handleFrame(frame: Buffer, handler: Handler) {
  const t = frame[0]
  const rest = frame.slice(1)
  if (t === 0) {
  } else if (t === 1) {
  } else if (t === 2) {
  }
}

function handleCall(frame: Buffer, handler: Handler) {
  const pidSize = frame.readUInt8(0)
  const pid = frame.slice(1, 1 + pidSize).toString()
  const tagSize = frame.readUInt8(1 + pidSize)
  const tag = frame.slice(2 + pidSize)
}

function reply(pid: Pid, tag: CallTag, term: any): void {
  Buffer.concat([
    Buffer.from([0]),
    Buffer.from([pid.length]),
    Buffer.from(pid),
    Buffer.from([tag.length]),
    Buffer.from(tag),
    Buffer.from(JSON.stringify(term)),
  ])
}

function send(buf: Buffer) {
  const len = Buffer.alloc(4)
  len.writeUint32BE(buf.byteLength)
  output.write(Buffer.concat([len, buf]))
}
