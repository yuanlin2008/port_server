defmodule PortServer.Frame do

  @type out_types :: :call | :cast | :down

  @spec serialize(out_types(), integer(), binary()) :: iodata()
  def serialize(type, conn_id, payload) do
    type_id = case type do
      :call -> 0
      :cast -> 1
      :down -> 2
    end
    [type_id, <<conn_id::64>>, payload]
  end

  @type in_types :: :call | :cast | :monitor

  @spec deserialize(binary()) :: {in_types(), integer(), binary()}
  def deserialize(bin) do
    <<type_id::8, conn_id::64, payload::binary>> = bin
    type = case type_id do
      0-> :call
      1-> :cast
      2-> :monitor
    end
    {type, conn_id, payload}
  end

end
