defmodule PortServerTest do
  use ExUnit.Case, async: true

  test "" do
    {:ok, pid} = PortServer.start({"npx", ["ts-node", "test.ts"], [dir: "./test"]})
    ret = PortServer.call(pid, %{a: 2, b: 3})
    assert ^ret = 5
  end
end
