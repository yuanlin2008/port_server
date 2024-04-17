defmodule PortServer.ChannelTable do
  @moduledoc """
  """
  use GenServer

  @doc """
  """
  @spec insert(owner :: pid(), server :: pid()) :: PortServer.channel()
  def insert(owner, server) do
    channel = :ets.update_counter(__MODULE__, :channel, 1, {:channel, 0})
    :ets.insert(__MODULE__, {channel, owner, server})
    channel
  end

  @doc """
  """
  @spec remove(channel :: PortServer.channel()) :: true
  def remove(channel) do
    :ets.delete(__MODULE__, channel)
  end

  @doc """
  """
  @spec get_owner(channel :: PortServer.channel()) :: pid()
  def get_owner(channel) do
    :ets.lookup_element(__MODULE__, channel, 2)
  end

  @doc """
  """
  @spec remove_server(server :: pid()) :: true
  def remove_server(server) do
    :ets.match_delete(__MODULE__, {:_, :_, server})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    __MODULE__ =
      :ets.new(__MODULE__, [
        :set,
        :public,
        :named_table,
        {:read_concurrency, true},
        {:write_concurrency, true}
      ])

    {:ok, nil}
  end
end
