defmodule PortServer.Channel do
  @moduledoc """
  """
  alias PortServer.ChannelTable
  use GenServer

  @type options :: {GenServer.server(), String.t(), term()}

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
  def init({server, topic, payload}) do
    server_pid = GenServer.whereis(server)
    # channel should be on the same node with server
    # because they share channel table.
    if node(server_pid) == node() do
      {:stop, "channel should be on the same node with server"}
    else
      mref = Process.monitor(server_pid)
      ChannelTable.insert(self(), server_pid)
      GenServer.call(server, {})
      {:ok, mref}
    end
  end

  @impl true
  def handle_info({:DOWN, mref, _, _, reason}, mref) do
    {:stop, reason, nil}
  end
end
