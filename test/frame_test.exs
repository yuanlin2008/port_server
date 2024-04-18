defmodule FrameTest do
  alias PortServer.Frame
  use ExUnit.Case, async: true

  test "serialize & deserialize" do
    type = 128
    id = 100
    payload = %{
      "aaa"=> 123,
      "bbb"=> false
    }

    assert {^type, ^id, bin} =
      Frame.serialize(type, id, payload)|>
      Frame.deserialize()
    assert ^payload = Jason.decode!(bin)
  end
end
