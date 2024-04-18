defmodule PortServer.Frame do

  @spec serialize(integer(), integer(), term()) :: binary()
  def serialize(type, id, payload) do
    :erlang.iolist_to_binary(
      [type, <<id::64>>,
      Jason.encode_to_iodata!(payload
      )])
  end

  @spec deserialize(binary()) :: {integer(), integer(), binary()}
  def deserialize(bin) do
    <<type::8, id::64, rest::binary>> = bin
    {type, id, rest}
  end

end
