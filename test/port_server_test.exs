defmodule PortServerTest do
  use ExUnit.Case
  doctest PortServer

  test "greets the world" do
    assert PortServer.hello() == :world
  end
end
