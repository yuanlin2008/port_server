defmodule PortServer.Transport do
  @callback init(options :: term()) :: transport :: term()
  @callback send(transport :: term(), data :: iodata()) :: boolean()
  @callback recv(transport :: term(), msg :: term()) ::
              data :: iodata() | {:error, reason :: term()}
end
