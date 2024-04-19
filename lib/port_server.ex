defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Frame
  alias PortServer.CallTable
  alias PortServer.Server
  alias PortServer.Transport.{Port, Socket}

  @typedoc """
  Options to be passed to start_link.
  """
  @type options :: {
          Port | Socket,
          Port.options() | Socket.options()
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
    frame = Frame.serialize(
      0,
      CallTable.insert(self(), timeout + 1000),
      %{
        name: name,
        payload: payload
    })
    GenServer.call(server, {:send, frame}, timeout)
  end


end
