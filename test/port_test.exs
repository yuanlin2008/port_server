defmodule PortTest do
  alias PortServer.Port
  use ExUnit.Case, async: true

  test "open exceptions" do
    # invalid cmd
    assert_raise ArgumentError, fn -> Port.open("123", [], []) end
    # invalid options
    assert_raise ArgumentError, fn -> Port.open("echo", ["123"], abc: 123) end
  end

  test "echo" do
    port = Port.open("node", ["echo.js"], dir: "./test")

    Enum.each(1..4096, fn i ->
      msg = "abcde#{i}"
      Port.command(port, msg)
      assert_receive {^port, {:data, ^msg}}
    end)
  end

  test "echo-ts" do
    port = Port.open("node", ["echo-ts.js"], dir: "./test")

    Enum.each(1..4096, fn i ->
      msg = "abcde#{i}"
      Port.command(port, msg)
      assert_receive {^port, {:data, ^msg}}, 1000
    end)
  end
end
