defmodule PortServer.ProcReg do
  @moduledoc """
  This module is used for transforming between pid and connection id.
  """
  use GenServer

  @type conn_id :: integer()

  @spec query_id(pid()) :: conn_id()
  def query_id(pid) when is_pid(pid) do
    try do
      :ets.lookup_element(__MODULE__, pid, 2)
    rescue
      ArgumentError ->
        GenServer.call(__MODULE__, {:pid, pid})
    end
  end

  @doc """
  Query pid of connection id.
  """
  @spec query_pid(conn_id()) :: pid() | nil
  def query_pid(conn_id) when is_integer(conn_id) do
    try do
      :ets.lookup_element(__MODULE__, conn_id, 2)
    rescue
      ArgumentError -> nil
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(__MODULE__, [
      :named_table,
      :set,
      :protected,
      {:read_concurrency, true},
    ])
    {:ok, 0}
  end

  @impl true
  def handle_call({:pid, pid}, _, id) do
    try do
      conn_id = :ets.lookup_element(__MODULE__, pid, 2)
      {:reply, conn_id, id}
    rescue
      ArgumentError ->
      :ets.insert(__MODULE__, [
        {pid, id},
        {id, pid}
        ])
      {:reply, id, id+1}
    end
  end

  @impl true
  def handle_info({:DOWN, _, :process, pid, :noproc}, state) do
    # clear ets.
    try do
      conn_id = :ets.lookup_element(__MODULE__, pid, 2)
      :ets.delete(__MODULE__, conn_id)
      :ets.delete(__MODULE__, pid)
    rescue
      ArgumentError -> :ok
    end
    {:noreply, state}
  end
end
