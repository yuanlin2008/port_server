defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialize & deserialize" do
    channel = 111
    payload = "abcdefg"

    {^channel, ^payload} =
      Frame.serialize(channel, payload)
      |> :erlang.iolist_to_binary()
      |> Frame.deserialize()
  end
end
