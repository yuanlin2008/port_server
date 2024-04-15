defmodule PortServer do
  alias PortServer.Transport.{Port, Socket}

  @moduledoc """
  Documentation for `PortServer`.
  """
  use GenServer

  @type options :: %{
          transport: :port | :socket,
          options: Port.options() | Socket.options()
        }

  @doc """
  """
  @spec start(options(), GenServer.options()) :: GenServer.on_start()
  def start(options, gs_options \\ []) do
    GenServer.start(__MODULE__, options, gs_options)
  end

  @doc """
  """
  @spec start_link(options(), GenServer.options()) :: GenServer.on_start()
  def start_link(options, gs_options \\ []) do
    GenServer.start_link(__MODULE__, options, gs_options)
  end

  @doc """
  """
  @spec call(GenServer.server(), String.t(), term()) :: term()
  def call(server, name, data) do
    # encode
    iodata = Jason.encode_to_iodata!(%{
      name: name,
      data: data
    })
    # call
    reply = GenServer.call(server, iodata)
    # decode
    Jason.decode!(reply)
  end

  @impl true
  def init(options) do
    {:ok, options, {:continue, :init}}
  end

  @ets_options [:set, :private]

  @impl true
  def handle_continue(:init, options) do
    # init transport
    transport_mod =
      case options.trasport do
        :port -> Port
        :socket -> Socket
      end

    # call transport.init
    transport = apply(transport_mod, :init, options.options)
    # init request table
    table = :ets.new(__MODULE__, @ets_options)

    {:noreply, {transport_mod, transport, table}}
  end

  @impl true
  def handle_call(request, from, {transport_mod, transport, table} = state) do
    {:noreply, state}
  end
end
