defmodule PortServer.Frame do

  @spec serialize(term(), binary()) :: iodata()
  def serialize(header, payload) do
    header = :erlang.term_to_binary(header)
    [<<byte_size(header)::32>>, header, payload]
  end

  @spec deserialize(binary()) :: {term(), binary()}
  def deserialize(bin) do
    <<header_size::32, header::binary-size(header_size), payload::binary>> = bin
    {:erlang.binary_to_term(header), payload}
  end

end
