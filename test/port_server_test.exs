defmodule PortServerTest do
  use ExUnit.Case, async: true

  def node_run(script, options \\ []) do
    PortServer.start({"node", ["-e", script], options})
  end

  test "invalid_options" do
    assert {:error, {:invalid_options, [abc: true]}} = PortServer.start({"cmd", [], [abc: true]})
  end

  test "start failed: cmd_not_found" do
    assert {:error, {:cmd_not_found, "123"}} = PortServer.start({"123"})
  end

  test "start failed: exit_status" do
    assert {:error, {:exit_status, 2}} = node_run("process.exit(2)")
  end

  test "start failed: start_timeout" do
    assert {:error, :start_timeout} =
             node_run("setTimeout(function(){},5000)", start_timeout: 1000)
  end

  def server_run(script, options \\ []) do
    {:ok, pid} =
      PortServer.start(
        {"node",
         [
           "-e",
           """
           const server = require("./src/server.js")
           #{script}
           server.start()
           """
         ], options}
      )

    pid
  end

  test "call" do
    pid =
      server_run("""
      server.on("call", function(pid, tag, payload){
        server.reply(pid, tag, payload.a + payload.b)
      })
      """)

    assert 3 == PortServer.call(pid, %{a: 1, b: 2})
  end

  test "cast" do
    pid =
      server_run("""
      server.on("cast", function(pid, payload){
        server.cast(pid, payload.a + payload.b)
      })
      """)

    PortServer.cast(pid, %{a: 1, b: 2})
    assert_receive {:"$gen_cast", 3}
  end

  test "monitor" do
    pid =
      server_run("""
      let down = false
      server.on("call", (pid, tag, payload)=>{
        if(payload === "register"){
          server.monitor(pid)
          server.reply(pid, tag, "ok")
        }else{
          server.reply(pid, tag, down)
        }
      })
      server.on("down", (pid)=>{down = true})
      """)

    Task.await(
      Task.async(fn ->
        assert "ok" = PortServer.call(pid, "register")
      end)
    )

    :timer.sleep(1000)
    assert true = PortServer.call(pid, "check")
  end

  test "concurrent call" do
    pid =
      server_run("""
      let down = false
      server.on("call", (pid, tag, payload)=>{
        setTimeout(()=> server.reply(pid, tag, payload), 1000)
      })
      """)

    Enum.map(1..4096, fn i ->
      Task.async(fn ->
        assert ^i = PortServer.call(pid, i)
      end)
    end)
    |> Task.await_many()
  end
end
