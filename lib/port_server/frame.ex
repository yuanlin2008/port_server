defmodule PortServer.Frame do
  @channel_size 64
  @spec serialize(PortServer.ChannelTable.channel(), iodata()) :: iodata()
  def serialize(channel, payload) do
    [<<channel::@channel_size>>, payload]
  end

  @spec deserialize(binary()) :: {PortServer.ChannelTable.channel(), binary()}
  def deserialize(bin) do
    <<channel::@channel_size, rest::binary>> = bin
    {channel, rest}
  end
end
