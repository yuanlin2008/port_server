function onFrame(input, frameCallbak) {
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

function sendFrame(output, frame) {
  // todo: handle 'drain'
  const buf = Buffer.concat(frame.bufs)
  const lenBuf = Buffer.alloc(4)
  lenBuf.writeUint32BE(buf.byteLength)
  output.write(Buffer.concat([lenBuf, buf]))
}

function Reader(buf) {
  this.buf = buf
  this.ptr = 0
}
Reader.prototype.readTerm = function () {
  return this.readBlock(0)
}
Reader.prototype.readString = function () {
  return this.readBlock(1)
}
Reader.prototype.readBlock = function (t) {
  if (t !== this.buf[this.ptr]) throw new Error("Invalid frame")
  this.ptr += 1
  const len = this.buf.readUInt32LE(this.ptr)
  this.ptr += 4
  const block = this.buf.toString(undefined, this.ptr, this.ptr + len)
  this.ptr += len
  return block
}

function Writer() {
  this.bufs = []
}
Writer.prototype.writeTerm = function (term) {
  this.writeBlock(0, term)
}
Writer.prototype.writeString = function (s) {
  this.writeBlock(1, s)
}
Writer.prototype.writeBlock = function (t, b) {
  this.bufs.push(Buffer.from([t]))
  const lenBuf = Buffer.allocUnsafe(4)
  lenBuf.writeUInt32LE(b.length)
  this.bufs.push(lenBuf)
  const sb = Buffer.allocUnsafe(b.length)
  sb.write(b)
  this.bufs.push(sb)
}

module.exports = {
  onFrame,
  sendFrame,
  Reader,
  Writer,
}
