defmodule CallRegTest do
  use ExUnit.Case, async: true
  alias PortServer.CallReg

  test "concurrent access" do
    procs = Enum.map(1..4096, fn i ->
      Task.async(fn ->
        calltag = "calltag#{i}"
        assert CallReg.query_calltag(self()) == nil
        CallReg.update_calltag(self(), "abc")
        assert CallReg.query_calltag(self()) == "abc"
        CallReg.update_calltag(self(), calltag)
        assert CallReg.query_calltag(self()) == calltag
        self()
      end)
    end)
    |> Task.await_many
    :timer.sleep(1000)
    Enum.each(procs, fn pid->
      assert CallReg.query_calltag(pid) == nil
    end)
  end
end
