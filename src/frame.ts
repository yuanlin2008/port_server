import { ReadStream, WriteStream } from "fs"

export function onFrame(
  input: ReadStream,
  frameCallbak: (frame: Buffer) => void
) {
  let length: number | null = null
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

export function sendFrame(output: WriteStream, frame: FrameWriter) {
  // todo: handle 'drain'
  const buf = Buffer.concat(frame.bufs)
  const lenBuf = Buffer.alloc(4)
  lenBuf.writeUint32BE(buf.byteLength)
  output.write(Buffer.concat([lenBuf, buf]))
}

export class FrameReader {
  private ptr: number = 0
  constructor(private buf: Buffer) {}
  readTerm() {
    return this.readBlock(0)
  }
  readString() {
    return this.readBlock(1)
  }
  private readBlock(t: number) {
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
  public bufs: Buffer[] = []
  constructor() {}
  writeTerm(pid: string) {
    this.writeBlock(0, pid)
  }
  writeString(s: string) {
    this.writeBlock(1, s)
  }
  private writeBlock(t: number, b: string) {
    this.bufs.push(Buffer.from([t]))
    const lenBuf = Buffer.allocUnsafe(4)
    lenBuf.writeUInt32LE(b.length)
    this.bufs.push(lenBuf)
    const sb = Buffer.allocUnsafe(b.length)
    sb.write(b)
    this.bufs.push(sb)
  }
}
