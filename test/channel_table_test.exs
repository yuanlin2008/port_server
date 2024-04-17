defmodule ChannelTableTest do
  alias PortServer.ChannelTable
  use ExUnit.Case

  @n 4096

  test "concurrent access" do
    Enum.map(1..@n, fn i ->
      Task.async(fn ->
        channel = ChannelTable.insert(i, 0)
        assert ChannelTable.get_owner(channel) == i
        ChannelTable.remove(channel)
        assert_raise ArgumentError, fn -> ChannelTable.get_owner(channel) end
        assert ChannelTable.remove(channel)
      end)
    end)
    |> Task.await_many()
  end

  test "remove all channels belong to server" do
    channels =
      Enum.map(1..@n, fn i ->
        Task.async(fn ->
          channel = ChannelTable.insert(i, 0)
          assert ChannelTable.get_owner(channel) == i
          channel
        end)
      end)
      |> Task.await_many()

    ChannelTable.remove_server(0)

    Enum.each(channels, fn channel ->
      assert_raise ArgumentError, fn -> ChannelTable.get_owner(channel) end
    end)
  end
end
