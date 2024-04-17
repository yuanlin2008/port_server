defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Server
  alias PortServer.Transport.{Port, Socket}

  @typedoc """
  Options to be passed to start_link.
  """
  @type options :: %{
          transport: Port | Socket,
          options: Port.options() | Socket.options()
        }

  @type channel :: integer()

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
  @spec open(GenServer.server(), String.t(), term(), timeout()) :: {channel(), term()}
  def open(server, topic, payload, timeout \\ 5000) do
    GenServer.call(server, {:open, topic, payload}, timeout)
  end

  @spec close(GenServer.server(), channel()) :: :ok
  def close(server, channel) do
    GenServer.cast(server, {:close, channel})
  end

  @doc """
  """
  @spec call(GenServer.server(), channel(), String.t(), term(), timeout()) :: term()
  def call(server, channel, name, payload, timeout \\ 5000) do
    GenServer.call(server, {:call, channel, name, payload}, timeout)
  end

  @doc """
  """
  @spec cast(GenServer.server(), channel(), String.t(), term()) :: :ok
  def cast(server, channel, name, payload) do
    GenServer.cast(server, {:cast, channel, name, payload})
  end
end
