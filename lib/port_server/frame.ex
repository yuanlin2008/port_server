defmodule PortServer.Frame do
  @moduledoc false

  def serialize(blocks)
      when is_list(blocks) do
    blocks
    |> Enum.map(fn term ->
      case term do
        bin when is_binary(term) ->
          # string
          [<<1::8, byte_size(bin)::32>>, bin]

        _ ->
          # term
          bin = :erlang.term_to_binary(term)
          [<<0::8, byte_size(bin)::32>>, bin]
      end
    end)
  end

  def deserialize(bin) when is_binary(bin) do
    for <<t::8, s::32, b::binary-size(s) <- bin>> do
      case t do
        # term
        0 -> :erlang.binary_to_term(b)
        # string
        1 -> b
      end
    end
  end
end
