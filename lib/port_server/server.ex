defmodule PortServer.Server do
  @moduledoc """
  """
  alias PortServer.ChannelTable
  alias PortServer.CallTable
  alias PortServer.Frame
  use GenServer

  @impl true
  def init(options) do
    # defer init
    {:ok, options, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {transport, options}) do
    port = transport.init(options)
    state = {transport, port}
    {:noreply, state}
  end

  @impl true
  def handle_call({:send, frame}, _, {transport, port} = state) do
    transport.send(port, frame)
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, {transport, port} = state) do
    case transport.recv(port, msg) do
      {:ok, frame}->
        handle_frame(frame)
        {:noreply, state}
      {:error, reason}->
        {:stop, reason}
      :ignore->
        {:noreply, state}
    end
  end

  defp handle_frame(bin) do
    {type, id, payload} = Frame.deserialize(bin)
    case type do
      0-> handle_call_frame(id, payload)
      1-> handle_channel_frame(id, payload)
    end
  end

  defp handle_call_frame(id, payload) do
    case CallTable.query(id) do
      nil-> :ok
      pid-> GenServer.reply(pid, payload)
    end
  end

  defp handle_channel_frame(id, payload) do
    case ChannelTable.query(id) do
      nil-> false
      pid-> GenServer.reply(pid, payload)
    end
  end
end
