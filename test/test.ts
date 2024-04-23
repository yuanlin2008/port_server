console.log("test from node")

process.on("uncaughtException", (e, ori) => {
  console.log("------------------------------")
  console.log(e)
})
process.on("uncaughtRejection", (r, p) => {
  console.log("=======================================")
  console.log(r)
})
setInterval(() => {
  console.log("finished")
  b()
}, 1000)

const a: any = 0
const b: any = undefined
console.log(b.ccc())
