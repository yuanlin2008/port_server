defmodule PortServer.Server do
  @moduledoc """
  """
  use GenServer
  alias PortServer.Frame
  alias PortServer.Transport.{Port, Socket}

  @impl true
  def init(options) do
    # defer init
    {:ok, options, {:continue, :init}}
  end

  @ets_options [:set, :private]

  @impl true
  def handle_continue(:init, options) do
    # init transport
    transport_mod =
      case options.transport do
        :port -> Port
        :socket -> Socket
      end

    # call transport.init
    transport = apply(transport_mod, :init, options.options)
    # init request table
    table = :ets.new(__MODULE__, @ets_options)

    state = %{
      transport_mod: transport_mod,
      transport: transport,
      table: table,
      id: 0
    }
    {:noreply, state}
  end

  @impl true
  def handle_call({:call, payload}, from, state) do
    id = state.id + 1
    iodata = Frame.serialize({:call, state.id, payload})
    {:noreply, %{state | id: id}}
  end
end
