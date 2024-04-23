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
  public type: number
  private ptr: number = 0
  constructor(private buf: Buffer) {
    this.type = this.buf.readUint8(this.ptr)
    this.ptr += 1
  }
  readString() {
    const len = this.buf.readUInt16LE(this.ptr)
    this.ptr += 2
    const r = this.buf.toString(undefined, this.ptr, this.ptr + len)
    this.ptr += len
    return r
  }
  readPayload() {
    const b = this.buf.slice(this.ptr)
    return JSON.parse(b as any)
  }
}

export class FrameWriter {
  public bufs: Buffer[] = []
  constructor(type: number) {
    this.bufs.push(Buffer.from([type]))
  }
  writeString(s: string) {
    const lenBuf = Buffer.allocUnsafe(2)
    lenBuf.writeUInt16LE(s.length)
    this.bufs.push(lenBuf)
    const sb = Buffer.allocUnsafe(s.length)
    sb.write(s)
    this.bufs.push(sb)
  }

  writePayload(payload: any) {
    const s = JSON.stringify(payload)
    const b = Buffer.from(s)
    this.bufs.push(b)
  }
}
