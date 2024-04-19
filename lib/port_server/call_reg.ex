defmodule PortServer.CallReg do
  @moduledoc """
  """
  use GenServer

  @spec query_calltag(pid()) :: term() | nil
  def query_calltag(pid) when is_pid(pid) do
    try do
      :ets.lookup_element(__MODULE__, pid, 2)
    rescue
      ArgumentError -> nil
    end
  end

  @spec update_calltag(pid(), term()) :: term()
  def update_calltag(pid, calltag) when is_pid(pid) do
    case :ets.insert_new(__MODULE__, {pid, calltag}) do
      true-> GenServer.cast(__MODULE__, {:monitor, pid})
      false-> :ets.insert(__MODULE__, {pid, calltag})
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(__MODULE__, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])
    {:ok, nil}
  end

  @impl true
  def handle_cast({:monitor, pid}, state) do
    # monitor this pid.
    Process.monitor(pid)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _, :process, pid, :noproc}, state) do
    # clear ets.
    :ets.delete(__MODULE__, pid)
    {:noreply, state}
  end
end
