defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialization" do
    id = 99
    blocks = [self(), "aaaa", make_ref(), self(), "abcde"]
    bin = Frame.serialize(id, blocks) |> :erlang.iolist_to_binary()
    assert {^id, ^blocks} = Frame.deserialize(bin)
  end
end
