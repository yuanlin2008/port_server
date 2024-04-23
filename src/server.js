import fs from "fs"
import { FrameReader, FrameWriter, onFrame, sendFrame } from "./frame"

// process.on("uncaughtException", (err, ori) => {
//   const s = `Caught exception: ${err}\n` + `Exception origin: ${ori}\n`
//   console.error(s)
//   const writer = new FrameWriter()
//   writer.writeString("exception")
//   writer.writeString(s)
//   sendFrame(output, writer)
// })

const input = fs.createReadStream(null, { fd: 3 })
const output = fs.createWriteStream(null, { fd: 4 })

export function reply(pid, tag, payload) {
  const writer = new FrameWriter()
  writer.writeString("reply")
  writer.writeTerm(pid)
  writer.writeTerm(tag)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function cast(pid, payload) {
  const writer = new FrameWriter()
  writer.writeString("cast")
  writer.writeTerm(pid)
  writer.writeString(JSON.stringify(payload))
  sendFrame(output, writer)
}

export function monitor(pid) {
  const writer = new FrameWriter()
  writer.writeString("monitor")
  writer.writeTerm(pid)
  sendFrame(output, writer)
}

export function start(handler) {
  onFrame(input, (frame) => {
    handleFrame(frame, handler)
  })
}

function handleFrame(frame, handler) {
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
