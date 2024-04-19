defmodule PortServer.ProcReg do
  @moduledoc """
  This module is used for transforming between pid and connection id.
  """
  use GenServer

  @type conn_id :: integer()

  @table_id Module.concat([__MODULE__, Id])
  @table Module.concat([__MODULE__, Table])

  @spec insert_pid(pid()) :: conn_id()
  def insert_pid(pid) when is_pid(pid) do
    conn_id = :ets.update_counter(@table_id, :id, 1, {:id, 0})
    :ets.insert(@table, [
      {pid, conn_id},
      {conn_id, pid}
      ])
    GenServer.cast(__MODULE__, {:monitor, pid})
    conn_id
  end

  @spec query_id(pid()) :: conn_id() | nil
  def query_id(pid) when is_pid(pid) do
    try do
      :ets.lookup_element(@table, pid, 2)
    rescue
      ArgumentError -> nil
    end
  end

  @doc """
  Query pid of connection id.
  """
  @spec query_pid(conn_id()) :: pid() | nil
  def query_pid(conn_id) when is_integer(conn_id) do
    try do
      :ets.lookup_element(@table, conn_id, 2)
    rescue
      ArgumentError -> nil
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table_id, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
    ])
    :ets.new(@table, [
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
    try do
      conn_id = :ets.lookup_element(@table, pid, 2)
      :ets.delete(@table, conn_id)
      :ets.delete(@table, pid)
    rescue
      ArgumentError -> :ok
    end
    {:noreply, state}
  end
end
