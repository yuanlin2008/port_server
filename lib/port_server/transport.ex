defmodule PortServer.Transport do
  @callback init(options :: term()) :: term()
  @callback send(port :: term(), msg :: iodata()) :: boolean()
  @callback recv(port :: term(), msg :: term()) :: {:ok, iodata()} | {:error, term()} | :ignore
end
