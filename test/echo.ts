import fs from "fs"
// const input = fs.createReadStream(null as any, { fd: 3 })
// const output = fs.createWriteStream(null as any, { fd: 4 })
const input = process.stdin
const output = process.stdout
let frame_length: any
let frame_buffer: any
let frame: any
let len: any
input.on("readable", () => {
  if (frame_length === undefined && null !== (frame_buffer = input.read(4))) {
    frame_length = frame_buffer.readUInt32BE(0, true)
  }
  if (
    frame_length !== undefined &&
    null !== (frame = input.read(frame_length))
  ) {
    len = Buffer.alloc(4)
    len.writeUInt32BE(frame_length)
    output.write(len)
    output.write(frame)
    frame_length = undefined
  }
})

console.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
