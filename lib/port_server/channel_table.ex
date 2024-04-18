defmodule PortServer.ChannelTable do
  @moduledoc """
  Table used to transform channel id to channel pid
  """
  use GenServer

  @type channel_id :: integer()

  @id_table Module.concat([__MODULE__, Id])
  @table __MODULE__
  @doc """
  """
  @spec insert(pid(), pid()) :: channel_id()
  def insert(channel_pid, server_pid) do
    channel_id = :ets.update_counter(@id_table, :id, 1, {:id, 0})
    :ets.insert(@table, {channel_id, channel_pid, server_pid})
    channel_id
  end

  @doc """
  """
  @spec remove(channel_id()) :: true
  def remove(channel_id) do
    :ets.delete(@table, channel_id)
  end

  @doc """
  """
  @spec remove_by_channel_pid(pid()) :: true
  def remove_by_channel_pid(channel_pid) do
    :ets.match_delete(@table, {:_, channel_pid, :_})
  end

  @doc """
  """
  @spec remove_by_server_pid(pid()) :: true
  def remove_by_server_pid(server_pid) do
    :ets.match_delete(@table, {:_, :_, server_pid})
  end

  @doc """
  """
  @spec query(channel_id()) :: pid() | nil
  def query(channel_id) do
    try do
      :ets.lookup_element(@table, channel_id, 2)
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

    {:ok, nil}
  end
end
