defmodule CallTableTest do
  alias PortServer.CallTable
  use ExUnit.Case

  @n 4096

  test "clear timeout" do
    call_ids =
      Enum.map(1..@n, fn i ->
        Task.async(fn ->
          call_id = CallTable.insert(i, 0)
          assert CallTable.query(call_id) == i
          call_id
        end)
      end)
      |> Task.await_many

    call_id = CallTable.insert(@n, 2)

    CallTable.clear_timeout(1)

    Enum.each(call_ids, fn call_id ->
      assert CallTable.query(call_id) == nil
    end)
    assert CallTable.query(call_id) == @n
    CallTable.clear_timeout(3)
    assert CallTable.query(call_id) == nil
  end
end
