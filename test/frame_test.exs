defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialize & deserialize" do
    id = 100
    name = "123"
    payload = %{
      aaa: 123,
      bbb: false
    }

    assert {:call, ^id, bin} = Frame.serialize(:call, id, name, payload)|>
      :erlang.iolist_to_binary|>
      Frame.deserialize()
    assert {:channel, ^id, bin} = Frame.serialize(:channel, id, name, payload)|>
      :erlang.iolist_to_binary|>
      Frame.deserialize()
  end
end
