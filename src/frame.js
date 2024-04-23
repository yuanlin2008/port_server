export function onFrame(
  input,
  frameCallbak
) {
  let length = null
  input.on("readable", () => {
    while (true) {
      if (length === null) length = readLength()
      if (length === null) return
      const frame = input.read(length)
      if (frame === null) return
      else {
        length = null
        frameCallbak(frame)
      }
    }
  })

  function readLength() {
    const buf = input.read(4)
    if (buf !== null) return buf.readUInt32BE(0)
    return null
  }
}

export function sendFrame(output, frame) {
  // todo: handle 'drain'
  const buf = Buffer.concat(frame.bufs)
  const lenBuf = Buffer.alloc(4)
  lenBuf.writeUint32BE(buf.byteLength)
  output.write(Buffer.concat([lenBuf, buf]))
}

export class FrameReader {
  ptr = 0
  constructor(buf) {}
  readTerm() {
    return this.readBlock(0)
  }
  readString() {
    return this.readBlock(1)
  }
  readBlock(t) {
    if (t !== this.buf[this.ptr]) throw new Error("Invalid frame")
    this.ptr += 1
    const len = this.buf.readUInt32LE(this.ptr)
    this.ptr += 4
    const block = this.buf.toString(undefined, this.ptr, this.ptr + len)
    this.ptr += len
    return block
  }
}

export class FrameWriter {
  bufs = []
  constructor() {}
  writeTerm(term) {
    this.writeBlock(0, term)
  }
  writeString(s) {
    this.writeBlock(1, s)
  }
  writeBlock(t, b) {
    this.bufs.push(Buffer.from([t]))
    const lenBuf = Buffer.allocUnsafe(4)
    lenBuf.writeUInt32LE(b.length)
    this.bufs.push(lenBuf)
    const sb = Buffer.allocUnsafe(b.length)
    sb.write(b)
    this.bufs.push(sb)
  }
}
