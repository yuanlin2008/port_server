defmodule PortServer.Server do
  @moduledoc """
  """
  alias PortServer.Port
  alias PortServer.CallReg
  alias PortServer.ProcReg
  alias PortServer.ChannelTable
  alias PortServer.CallTable
  alias PortServer.Frame
  use GenServer

  @impl true
  def init({prog, args, options}) do
    port = Port.open(prog, args, options)
    {:ok, port}
  end

  @impl true
  def handle_call({:call,payload}, {pid, tag}, port) do
    conn_id = ProcReg.query_id(pid)
    CallReg.update_calltag(pid, tag)
    cmd = Frame.serialize(:call, conn_id, payload)
    Port.command(port, cmd)
    {:noreply, port}
  end

  @impl true
  def handle_cast({:cast, pid, payload}, port) do
    conn_id = ProcReg.query_id(pid)
    cmd = Frame.serialize(:cast, conn_id, payload)
    Port.command(port, cmd)
    {:noreply, port}
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
