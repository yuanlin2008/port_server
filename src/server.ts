import fs from "fs"
import { FrameReader, FrameWriter, onFrame, sendFrame } from "./frame"

export type Pid = string
export type CallTag = string

export interface Handler {
  handleCall(pid: Pid, tag: CallTag, payload: any): void
  handleCast(pid: Pid, payload: any): void
  handleDown(pid: Pid): void
}
process.on("uncaughtException", (err, ori) => {
  const s = `Caught exception: ${err}\n` + `Exception origin: ${ori}\n`
  const writer = new FrameWriter(255)
  writer.writePayload(s)
})
const input = fs.createReadStream("", { fd: 3 })
const output = fs.createWriteStream("", { fd: 4 })

export function reply(pid: Pid, tag: CallTag, payload: any) {
  const writer = new FrameWriter(0)
  writer.writePid(pid)
  writer.writeRef(tag)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function cast(pid: Pid, payload: any) {
  const writer = new FrameWriter(1)
  writer.writePid(pid)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function monitor(pid: Pid) {
  const writer = new FrameWriter(2)
  writer.writePid(pid)
  sendFrame(output, writer)
}

export function start(handler: Handler) {
  onFrame(input, (frame) => {
    handleFrame(frame, handler)
  })
}

function handleFrame(frame: Buffer, handler: Handler) {
  const reader = new FrameReader(frame)
  const t = reader.type
  if (t === 0) {
    const pid = reader.readPid()
    const tag = reader.readRef()
    const payload = reader.readString()
    handler.handleCall(pid, tag, JSON.parse(payload))
  } else if (t === 1) {
    const pid = reader.readPid()
    const payload = reader.readString()
    handler.handleCast(pid, JSON.parse(payload))
  } else if (t === 2) {
    const pid = reader.readPid()
    handler.handleDown(pid)
  }
}
