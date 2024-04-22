defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Frame
  alias PortServer.Server

  @typedoc """
  Options to be passed to start_link.
  """
  @type options :: {String.t(), [String.t()], Keyword.t}

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
    payload = Jason.encode!(%{
      name: name,
      payload: payload
    })
    GenServer.call(server, {:call, payload}, timeout)|>
    Jason.decode()
  end

  @spec cast(GenServer.server(), String.t(), term()) :: term()
  def cast(server, name, payload) do
    payload = Jason.encode!(%{
      name: name,
      payload: payload
    })
    frame = Frame.serialize({:cast, self()}, payload)
    GenServer.cast(server, {:cast, frame})
  end

end
