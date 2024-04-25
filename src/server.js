"use strict"

const fs = require("fs")
const { Reader, Writer, recv, send } = require("./frame.js")

// process.on("uncaughtException", (err, ori) => {
//   const s = `Caught exception: ${err}\n` + `Exception origin: ${ori}\n`
//   console.error(s)
//   const writer = new Writer()
//   writer.writeString("exception")
//   writer.writeString(s)
//   send(output, writer)
// })

const input = fs.createReadStream(null, { fd: 3 })
const output = fs.createWriteStream(null, { fd: 4 })

const downCallbacks = new Map()
const callCallbacks = new Map()
const castCallbacks = new Map()

/**
 * Reply to a call from pid.
 * @param {*} pid
 * @param {*} tag
 * @param {*} payload
 */
exports.reply = function (pid, tag, payload) {
  const writer = new Writer()
  writer.writeString("reply")
  writer.writeTerm(pid)
  writer.writeTerm(tag)
  writer.writeString(JSON.stringify(payload))
  send(output, writer)
}

/**
 * Cast a message to pid.
 */
exports.cast = function (pid, msg, payload) {
  const writer = new Writer()
  writer.writeString("cast")
  writer.writeTerm(pid)
  writer.writeString(msg)
  writer.writeString(JSON.stringify(payload))
  send(output, writer)
}

/**
 * monitor pid's down event.
 */
exports.monitor = function (pid, callback) {
  if (downCallbacks.has(pid)) {
    throw new Error(`Pid(${pid} already monitored)`)
  }
  downCallbacks.set(pid, callback)
  const writer = new Writer()
  writer.writeString("monitor")
  writer.writeTerm(pid)
  send(output, writer)
}

const handlers = {
  call(reader) {
    const pid = reader.readTerm()
    const tag = reader.readTerm()
    const msg = reader.readString()
    const payload = reader.readString()
    const callback = callCallbacks.get(msg)
    callback(pid, tag, JSON.parse(payload))
  },
  cast(reader) {
    const pid = reader.readTerm()
    const msg = reader.readString()
    const payload = reader.readString()
    const callback = castCallbacks.get(msg)
    callback(pid, JSON.parse(payload))
  },
  down(reader) {
    const pid = reader.readTerm()
    const cb = downCallbacks.get(pid)
    downCallbacks.delete(pid)
    cb(pid)
  },
}

/**
 * Register call handler.
 * @param {*} msg
 * @param {*} callback
 */
exports.onCall = function (msg, callback) {
  callCallbacks.set(msg, callback)
}

/**
 * Register cast handler.
 * @param {*} msg
 * @param {*} callback
 */
exports.onCast = function (msg, callback) {
  castCallbacks.set(msg, callback)
}

/**
 * Start the port server.
 */
exports.start = function () {
  recv(input, (frame) => {
    handleFrame(frame)
  })
  const writer = new Writer()
  writer.writeString("started")
  send(output, writer)
}

function handleFrame(frame) {
  const reader = new Reader(frame)
  const t = reader.readString()
  handlers[t](reader)
}
