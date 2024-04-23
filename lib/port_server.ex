defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Frame
  alias PortServer.Server

  @typedoc """
  Options to be passed to start_link.
  """
  @type options :: {String.t(), [String.t()], Keyword.t()}

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
  @spec call(GenServer.server(), term(), timeout()) :: term()
  def call(server, payload, timeout \\ 5000) do
    payload = Jason.encode!(payload)

    GenServer.call(server, {:call, payload}, timeout)
    |> Jason.decode!()
  end

  @spec cast(GenServer.server(), term()) :: term()
  def cast(server, payload) do
    payload = Jason.encode!(payload)
    frame = Frame.serialize(1, [self(), payload])
    GenServer.cast(server, {:cast, frame})
  end
end
