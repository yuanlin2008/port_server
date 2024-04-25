# PortServer

By using PortServer, you can implement a GenServer using NodeJS.

Features:

- Support `call`, `cast` and `monitor` function of GenServer.

- `call` can be handled asynchronously in NodeJS.

## Installation

### Elixir

Add PortServer as dependency to your Mix project:

```elixir
def deps do
  [{:port_server, "~> 0.1.0"}]
end
```

### NodeJS

```
npm install port-server
```

## Usage

### Implement `call` using NodeJS

JS

```javascript
const server = require("port-server")

server.onCall("hello", (pid, tag, payload) => {
  server.reply(pid, tag, "hello " + payload)
})
server.start()
```

Elixir

```elixir
iex> {:ok, pid} = PortServer.start({"node", ["index.js"],[]})
{:ok, #PID<0.195.0>}
iex> PortServer.call(pid, "hello", "world")
"hello world"
```

`call` can be handled asynchronously.
An "async" call handling will not block others.
It means that calling from multiple processes will be handled concurrently.

```javascript
const server = require("port-server")

server.onCall("hello", (pid, tag, payload) => {
  setTimeout(() => {
    server.reply(pid, tag, "hello " + payload)
  }, 5000)
})
server.start()
```

### Implement `cast` using NodeJS

JS

```javascript
const server = require("port-server")

server.onCast("ping", (pid, payload) => {
  server.cast(pid, "pong ", payload)
})
server.start()
```

Elixir

```elixir
iex> {:ok, pid} = PortServer.start({"node", ["index.js"],[]})
{:ok, #PID<0.195.0>}
iex> PortServer.cast(pid, "ping", "123")
:ok
iex> flush
{:"$gen_cast", {"pong", "123"}}
:ok
```

### Implement `monitor` using NodeJS

JS

```javascript
const server = require("port-server")

function down(pid) {
  // handle Pid `DOWN` event.
  console.log(`Pid(${pid}) is down!`)
}

server.onCast("test_monitor", (pid, payload) => {
  server.monitor(pid, down)
})

server.start()
```
