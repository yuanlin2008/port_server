defmodule ProcRegTest do
  use ExUnit.Case, async: true
  alias PortServer.ProcReg

  test "query the same pid by multiple process" do
    pid = spawn(fn-> receive do _ -> :ok end end)
    ids = Enum.map(1..4096, fn _ ->
        Task.async(fn ->
          ProcReg.query_id(pid)
        end)
      end)
      |> Task.await_many
    chk_id = ProcReg.query_id(pid)
    assert Enum.all?(ids, &(&1 == chk_id))
  end
end
