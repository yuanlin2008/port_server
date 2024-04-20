defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialize & deserialize" do
    chan_id = 100
    Enum.map(Frame.types, fn {k,_}->
      assert {^k, ^chan_id, "abc"} =
        Frame.serialize(k, chan_id, "abc")
        |>:erlang.iolist_to_binary
        |>Frame.deserialize
    end)
  end
end
