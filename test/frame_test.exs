defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialize & deserialize" do
    header = {:abc, "abcdef"}
    payload = "12345678"
    bin = Frame.serialize(header, payload)|>:erlang.iolist_to_binary
    assert {^header, ^payload} = Frame.deserialize(bin)
  end
end
