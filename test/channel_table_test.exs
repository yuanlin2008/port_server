defmodule ChannelTableTest do
  alias PortServer.ChannelTable
  use ExUnit.Case

  @n 4096

  test "concurrent access" do
    Enum.map(1..@n, fn i ->
      Task.async(fn ->
        chan_id = ChannelTable.insert(i, 0)
        assert ChannelTable.query(chan_id) == i
        ChannelTable.remove(chan_id)
        assert ChannelTable.query(chan_id) == nil
        assert ChannelTable.remove(chan_id)
      end)
    end)
    |> Task.await_many()
  end

  test "remove channels by server pid" do
    chan_ids =
      Enum.map(1..@n, fn i ->
        Task.async(fn ->
          chan_id = ChannelTable.insert(i, 0)
          assert ChannelTable.query(chan_id) == i
          chan_id
        end)
      end)
      |> Task.await_many()

    ChannelTable.remove_by_server_pid(0)

    Enum.each(chan_ids, fn chan_id ->
      assert ChannelTable.query(chan_id) == nil
    end)
  end

  test "remove channels by channel pid" do
    chan_ids =
      Enum.map(1..@n, fn _ ->
        Task.async(fn ->
          chan_id = ChannelTable.insert(0, 0)
          assert ChannelTable.query(chan_id) == 0
          chan_id
        end)
      end)
      |> Task.await_many()

    ChannelTable.remove_by_channel_pid(0)

    Enum.each(chan_ids, fn chan_id ->
      assert ChannelTable.query(chan_id) == nil
    end)
  end
end
