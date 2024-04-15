defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  use GenServer

  @type port_options :: {:port, String.t(), String.t()}
  @type socket_options :: {:socket}
  @type options :: port_options() | socket_options()

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

  @impl true
  def init(options) do
    {:ok, options, {:continue, :init}}
  end

  @ets_options [ :set, :private ]

  @impl true
  def handle_continue(:init, {:port, cmd, dir}) do
    # init transport
    port = Port.open({:spawn, cmd}, [{:cd, dir}|@port_options])
    # init request table
    table = :ets.new(__MODULE__, @ets_options)
    {:noreply, %{port: port, table: table}}
  end
end
