defmodule PortServer.Frame do
  def serialize(id, blocks)
      when is_number(id) and
             id >= 0 and
             id < 256 and
             is_list(blocks) do
    [
      id,
      blocks
      |> Enum.map(fn term ->
        case term do
          pid when is_pid(pid) ->
            bin = :erlang.term_to_binary(pid)
            [<<0::8, byte_size(bin)::32>>, bin]

          ref when is_reference(ref) ->
            bin = :erlang.term_to_binary(ref)
            [<<1::8, byte_size(bin)::32>>, bin]

          bin when is_binary(term) ->
            [<<2::8, byte_size(bin)::32>>, bin]
        end
      end)
    ]
  end

  def deserialize(bin) when is_binary(bin) do
    <<id::8, rest::binary>> = bin

    blocks =
      for <<t::8, s::32, b::binary-size(s) <- rest>> do
        case t do
          0 -> :erlang.binary_to_term(b)
          1 -> :erlang.binary_to_term(b)
          2 -> b
        end
      end

    {id, blocks}
  end
end
