defmodule PortTest do
  alias PortServer.Port
  use ExUnit.Case, async: true

  test "open exceptions" do
    # invalid cmd
    assert_raise ArgumentError, fn -> Port.open("123", [], []) end
    # invalid options
    assert_raise ArgumentError, fn -> Port.open("echo", ["123"], abc: 123) end
  end

  test "exit_status" do
    # exit 0
    port = Port.open("echo", ["123"], [])
    assert_receive {^port, {:exit_status, 0}}
    # exit 1
    port = Port.open("node", ["123"], [])
    assert_receive {^port, {:exit_status, 1}}
  end

  test "port" do
    port = Port.open("node", ["port_test.js"], dir: "./test")

    Enum.each(1..4096, fn i ->
      msg = "abcde#{i}"
      Port.command(port, msg)
      assert_receive {^port, {:data, ^msg}}
    end)
  end
end
