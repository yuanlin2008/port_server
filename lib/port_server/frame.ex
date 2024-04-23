defmodule PortServer.Frame do
  def serialize(blocks)
      when is_list(blocks) do
    blocks
    |> Enum.map(fn term ->
      case term do
        bin when is_binary(term) ->
          [<<1::8, byte_size(bin)::32>>, bin]

        _ ->
          bin = :erlang.term_to_binary(term)
          [<<0::8, byte_size(bin)::32>>, bin]
      end
    end)
  end

  def deserialize(bin) when is_binary(bin) do
    for <<t::8, s::32, b::binary-size(s) <- bin>> do
      case t do
        0 -> :erlang.binary_to_term(b)
        1 -> b
      end
    end
  end
end
