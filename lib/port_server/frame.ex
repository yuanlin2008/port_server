defmodule PortServer.Frame do
  @spec serialize(:call|:channel, integer(), String.t(), term()) :: iolist()
  def serialize(type, id, name, payload) do
    [transform_type(type), <<id::64>>,
    Jason.encode_to_iodata!(%{
      name: name,
      payload: payload
    })]
  end

  @spec deserialize(binary()) :: {:call|:channel, integer(), binary()}
  def deserialize(bin) do
    <<type::8, id::64, rest::binary>> = bin
    {transform_type(type), id, rest}
  end

  defp transform_type(t) do
    case t do
      :call->0
      :channel->1
      0->:call
      1->:channel
    end
  end
end
