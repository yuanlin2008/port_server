defmodule PortTest do
  alias PortServer.Port
  use ExUnit.Case, async: true
  test "port" do
    port = Port.open("node", ["port_test.js"], [dir: "./test"])
    Enum.each(1..4096, fn i->
      msg = "abcde#{i}"
      Port.command(port, msg)
      assert_receive {^port, {:data, ^msg}}
    end)
  end
end
