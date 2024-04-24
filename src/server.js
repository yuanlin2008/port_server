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
 * @param {*} pid
 * @param {*} payload
 */
exports.cast = function (pid, payload) {
  const writer = new Writer()
  writer.writeString("cast")
  writer.writeTerm(pid)
  writer.writeString(JSON.stringify(payload))
  send(output, writer)
}

/**
 * monitor pid's down event.
 * @param {*} pid
 */
exports.monitor = function (pid) {
  const writer = new Writer()
  writer.writeString("monitor")
  writer.writeTerm(pid)
  send(output, writer)
}

const handlers = {
  call(reader, cb) {
    const pid = reader.readTerm()
    const tag = reader.readTerm()
    const payload = reader.readString()
    cb(pid, tag, JSON.parse(payload))
  },
  cast(reader, cb) {
    const pid = reader.readTerm()
    const payload = reader.readString()
    cb(pid, JSON.parse(payload))
  },
  down(reader, cb) {
    const pid = reader.readTerm()
    cb(pid)
  },
}

const callbacks = {}

/**
 * Set event callback.
 * @param {*} event
 * @param {*} callback
 */
exports.on = function (event, callback) {
  callbacks[event] = callback
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
  if (callbacks[t] === undefined) return
  handlers[t](reader, callbacks[t])
}
