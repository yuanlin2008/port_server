defmodule PortServer.Frame.Types do
  defmacro types(types) when is_list(types) do
    [
      quote do
        def types do
          unquote(types)
        end
      end
    ]
    ++
    for {key, value} <- types do
      quote do
        defp type(unquote(value)), do: unquote(key)
        defp id(unquote(key)), do: unquote(value)
      end
    end
  end
end

defmodule PortServer.Frame do
  import PortServer.Frame.Types

  types(
    call: 0,
    cast: 1,
    monitor: 2,
    down: 3
  )

  @spec serialize(atom(), integer(), binary()) :: iodata()
  def serialize(type, conn_id, payload) do
    [id(type), <<conn_id::64>>, payload]
  end

  @spec deserialize(binary()) :: {atom(), integer(), binary()}
  def deserialize(bin) do
    <<id::8, conn_id::64, payload::binary>> = bin
    {type(id), conn_id, payload}
  end

end
