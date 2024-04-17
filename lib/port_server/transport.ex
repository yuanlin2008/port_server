defmodule PortServer.Transport do
  @callback init(options :: term()) :: transport :: term()
  @callback send(msg :: iodata(), transport :: term()) :: boolean()
  @callback recv(transport :: term(), msg :: term()) ::
              data :: iodata() | {:error, reason :: term()}
end
