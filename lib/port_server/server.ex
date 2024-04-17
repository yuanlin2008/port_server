defmodule PortServer.Server do
  @moduledoc """
  """
  use GenServer
  alias PortServer.ChannelTable

  @impl true
  def init(options) do
    # defer init
    {:ok, options, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, options) do
    transport_state = options.transport.init(options.options)
    state = {options.transport, transport_state}
    {:noreply, state}
  end

  @impl true
  def handle_call({:open, topic, payload}, {owner,_}, {transport, trans_state} = state) do
    #mref = Process.monitor(owner)
    %{
      type: :open,
      channel: ChannelTable.insert(owner, self()),
      topic: topic,
      payload: payload
    }|>encode!|>transport.send(trans_state)
    {:noreply, state}
  end

  def handle_call({}, from, state) do

  end

  # @impl true
  # def handle_call({:call, payload}, from, state) do
  #   id = state.id + 1
  #   iodata = Frame.serialize({:call, state.id, payload})
  #   {:noreply, %{state | id: id}}
  # end

  defp encode!(term), do: Jason.encode_to_iodata!(term, [])
  defp decode!(bin), do: Jason.decode!(bin, keys: :atom!)
end
