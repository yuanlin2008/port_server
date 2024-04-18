defmodule PortServer.CallTable do
  @moduledoc """
  """
  use GenServer

  @type call_id :: integer()

  @id_table Module.concat([__MODULE__, Id])
  @table __MODULE__

  @doc """
  """
  @spec insert(pid(), non_neg_integer()) :: call_id()
  def insert(pid, timeout) do
    call_id = :ets.update_counter(@id_table, :id, 1, {:id, 0})
    time = :os.system_time(:millisecond) + timeout
    :ets.insert(@table, {call_id, pid, time})
    call_id
  end

  @doc """
  """
  @spec clear_timeout() :: non_neg_integer()
  def clear_timeout() do
    time = :os.system_time(:millisecond)
    :ets.select_delete(@table, [{
      {:_, :_, :"$1"},
      [{:<, :"$1", time}],
      [true]
      }])
  end

  @doc """
  """
  @spec query(call_id()) :: pid() | nil
  def query(call_id) do
    try do
      :ets.lookup_element(@table, call_id, 2)
    rescue
      ArgumentError -> nil
    end
  end


  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    :ets.new(@id_table, [
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

    {:ok, nil, timeout()}
  end

  @impl true
  def handle_info(:timeout, state) do
    {:noreply, state, timeout()}
  end

  defp timeout() do
    Application.get_env(:port_server, :clear_duration, 60000)
  end
end
