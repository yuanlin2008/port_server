defmodule CallTableTest do
  alias PortServer.CallTable
  use ExUnit.Case

  @n 4096

  test "clear timeout" do
    call_ids =
      Enum.map(1..@n, fn i ->
        Task.async(fn ->
          call_id = CallTable.insert(i, 1000)
          assert CallTable.query(call_id) == i
          call_id
        end)
      end)
      |> Task.await_many

    call_id = CallTable.insert(@n, 2000)

    assert CallTable.clear_timeout() == 0
    :timer.sleep(1500)
    assert CallTable.clear_timeout() == @n

    Enum.each(call_ids, fn call_id ->
      assert CallTable.query(call_id) == nil
    end)
    assert CallTable.query(call_id) == @n
    :timer.sleep(1500)
    CallTable.clear_timeout()
    assert CallTable.query(call_id) == nil
  end
end
