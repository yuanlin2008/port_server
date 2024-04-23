import fs from "fs"
import { FrameReader, FrameWriter, onFrame, sendFrame } from "./frame"

export type Pid = string
export type CallTag = string

export interface Handler {
  handleCall(pid: Pid, tag: CallTag, payload: any): void
  handleCast(pid: Pid, payload: any): void
  handleDown(pid: Pid): void
}
// process.on("uncaughtException", (err, ori) => {
//   const s = `Caught exception: ${err}\n` + `Exception origin: ${ori}\n`
//   console.error(s)
//   const writer = new FrameWriter()
//   writer.writeString("exception")
//   writer.writeString(s)
//   sendFrame(output, writer)
// })

const input = fs.createReadStream("", { fd: 3 })
const output = fs.createWriteStream("", { fd: 4 })

export function reply(pid: Pid, tag: CallTag, payload: any) {
  const writer = new FrameWriter()
  writer.writeString("reply")
  writer.writeTerm(pid)
  writer.writeTerm(tag)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function cast(pid: Pid, payload: any) {
  const writer = new FrameWriter()
  writer.writeString("cast")
  writer.writeTerm(pid)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function monitor(pid: Pid) {
  const writer = new FrameWriter()
  writer.writeString("monitor")
  writer.writeTerm(pid)
  sendFrame(output, writer)
}

export function start(handler: Handler) {
  onFrame(input, (frame) => {
    handleFrame(frame, handler)
  })
}

function handleFrame(frame: Buffer, handler: Handler) {
  const reader = new FrameReader(frame)
  const t = reader.readString()
  if (t === "call") {
    const pid = reader.readTerm()
    const tag = reader.readTerm()
    const payload = reader.readString()
    handler.handleCall(pid, tag, JSON.parse(payload))
  } else if (t === "cast") {
    const pid = reader.readTerm()
    const payload = reader.readString()
    handler.handleCast(pid, JSON.parse(payload))
  } else if (t === "down") {
    const pid = reader.readTerm()
    handler.handleDown(pid)
  }
}
