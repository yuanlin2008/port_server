defmodule PortServer.CallTable do
  @moduledoc """
  """
  use GenServer

  @doc """
  """
  @spec insert(caller :: pid(), server :: pid()) :: integer()
  def insert(caller, server) do
    id = :ets.update_counter(__MODULE__, :id, 1, {:id, 0})
    :ets.insert(__MODULE__, {id, caller, server})
    id
  end

  @spec remove(id :: integer()) :: pid()
  def remove(id) do
    caller = :ets.lookup_element(__MODULE__, id, 2)
    :ets.delete(__MODULE__, id)
    caller
  end

  @spec remove_server(server :: pid()) :: true
  def remove_server(server) do
    :ets.match_delete(__MODULE__, {:_, :_, server})
  end

  @impl true
  def init(_) do
    :ets.new(__MODULE__, [:set, :named_table, ])
    __MODULE__ = :ets.new(__MODULE__, [
      :set,
      :public,
      :named_table,
      {:read_concurrency, true},
      {:write_concurrency, true}
      ])
      {:ok, nil}
  end
end
