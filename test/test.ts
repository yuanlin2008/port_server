import { start, reply } from "../src"

start({
  handleCall(pid, tag, payload) {
    reply(pid, tag, payload.a + payload.b)
  },
  handleCast(pid, payload) {},
  handleDown(pid) {},
})
