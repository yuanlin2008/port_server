defmodule ProcRegTest do
  use ExUnit.Case, async: true
  alias PortServer.ProcReg

  test "concurrent access" do
    procs = Enum.map(1..4096, fn _ ->
      Task.async(fn ->
        assert ProcReg.query_id(self()) == nil
        conn_id = ProcReg.insert_pid(self())
        assert ProcReg.query_id(self()) == conn_id
        assert ProcReg.query_pid(conn_id) == self()
        {self(), conn_id}
      end)
    end)
    |> Task.await_many
    :timer.sleep(1000)
    Enum.each(procs, fn {pid, conn_id}->
      assert ProcReg.query_id(pid) == nil
      assert ProcReg.query_pid(conn_id) == nil
    end)
  end
end
