import fs from "fs"
import { FrameReader, FrameWriter, onFrame, sendFrame } from "./frame"

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

  onFrame(input, (frame) => {
    handleFrame(frame, handler)
  })

  return {
    reply(pid: Pid, tag: CallTag, payload: any) {
      const writer = new FrameWriter(0)
      writer.writeString(pid)
      writer.writeString(tag)
      writer.writePayload(payload)
      sendFrame(output, writer)
    },
    cast(pid: Pid, payload: any) {
      const writer = new FrameWriter(1)
      writer.writeString(pid)
      writer.writePayload(payload)
      sendFrame(output, writer)
    },
    monitor(pid: Pid) {
      const writer = new FrameWriter(2)
      writer.writeString(pid)
      sendFrame(output, writer)
    },
  }
}

function handleFrame(frame: Buffer, handler: Handler) {
  const reader = new FrameReader(frame)
  const t = reader.type
  if (t === 0) {
    const pid = reader.readString()
    const tag = reader.readString()
    const payload = reader.readPayload()
    handler.handleCall(pid, tag, payload.name, payload.payload)
  } else if (t === 1) {
    const pid = reader.readString()
    const payload = reader.readPayload()
    handler.handleCast(pid, payload.name, payload.payload)
  } else if (t === 2) {
    const pid = reader.readString()
    handler.handleDown(pid)
  }
}
