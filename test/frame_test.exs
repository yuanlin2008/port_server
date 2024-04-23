defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialization" do
    blocks = [self(), "aaaa", make_ref(), self(), "abcde"]
    bin = Frame.serialize(blocks) |> :erlang.iolist_to_binary()
    assert ^blocks = Frame.deserialize(bin)
  end
end
