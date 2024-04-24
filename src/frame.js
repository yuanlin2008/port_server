"use strict"

/**
 * Receive a frame from erlang.
 * @param {*} input
 * @param {*} frameCallbak
 */
exports.recv = function (input, frameCallbak) {
  let length = null
  input.on("readable", () => {
    while (true) {
      if (length === null) {
        const buf = input.read(4)
        if (buf !== null) {
          length = buf.readUInt32BE(0)
        }
      }
      if (length === null) return
      const frame = input.read(length)
      if (frame === null) return
      else {
        length = null
        frameCallbak(frame)
      }
    }
  })
}

/**
 * Send a frame to erlang
 * @param {*} output
 * @param {*} frame
 */
exports.send = function (output, frame) {
  // todo: handle 'drain'
  const buf = Buffer.concat(frame.bufs)
  const lenBuf = Buffer.alloc(4)
  lenBuf.writeUint32BE(buf.byteLength)
  output.write(Buffer.concat([lenBuf, buf]))
}

const encoding = [
  // term.
  "hex",
  // string.
  "utf8",
]

/**
 * Frame Reader.
 * @param {*} buf
 */
exports.Reader = function (buf) {
  this.buf = buf
  this.ptr = 0
}
exports.Reader.prototype.readTerm = function () {
  return this.readBlock(0)
}
exports.Reader.prototype.readString = function () {
  return this.readBlock(1)
}
exports.Reader.prototype.readBlock = function (t) {
  if (t !== this.buf[this.ptr]) throw new Error("Invalid frame")
  this.ptr += 1
  const len = this.buf.readUInt32BE(this.ptr)
  this.ptr += 4
  const block = this.buf.toString(encoding[t], this.ptr, this.ptr + len)
  this.ptr += len
  return block
}

/**
 * Frame Writer.
 */
exports.Writer = function () {
  this.bufs = []
}
exports.Writer.prototype.writeTerm = function (term) {
  this.writeBlock(0, term)
}
exports.Writer.prototype.writeString = function (s) {
  this.writeBlock(1, s)
}
exports.Writer.prototype.writeBlock = function (t, b) {
  this.bufs.push(Buffer.from([t]))
  const lenBuf = Buffer.allocUnsafe(4)
  lenBuf.writeUInt32BE(b.length)
  this.bufs.push(lenBuf)
  const sb = Buffer.allocUnsafe(b.length)
  sb.write(b, encoding[t])
  this.bufs.push(sb)
}
