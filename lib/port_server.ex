defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Server

  @typedoc """
  Options to be passed to start_link.
  """
  @type options :: %{
          transport: :port | :socket,
          options: Port.options() | Socket.options()
        }

  @doc """
  """
  @spec start(options(), GenServer.options()) :: GenServer.on_start()
  def start(options, gs_options \\ []) do
    GenServer.start(Server, options, gs_options)
  end

  @doc """
  """
  @spec start_link(options(), GenServer.options()) :: GenServer.on_start()
  def start_link(options, gs_options \\ []) do
    GenServer.start_link(Server, options, gs_options)
  end

  @doc """
  """
  @spec call(GenServer.server(), String.t(), term(), timeout()) :: term()
  def call(server, name, payload, timeout \\ 5000) do
    # encode
    iodata = Jason.encode_to_iodata!(%{
      name: name,
      payload: payload
    })
    # call
    reply = GenServer.call(server, {:call, iodata}, timeout)
    # decode
    Jason.decode!(reply)
  end

end
