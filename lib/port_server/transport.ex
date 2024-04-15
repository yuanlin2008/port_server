defmodule PortServer.Transport do
  @callback init(options::term()) :: transport::term()
  @callback send(transport::term(), data::binary()) :: boolean()
  @callback handle_recv(transport::term()) :: :ok | {:error, reason::term()}
end
