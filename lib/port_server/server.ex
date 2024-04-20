defmodule PortServer.Server do
  @moduledoc """
  """
  alias PortServer.Port
  alias PortServer.CallReg
  alias PortServer.ProcReg
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
    cmd = Frame.serialize(:ps_call, conn_id, payload)
    Port.command(port, cmd)
    {:noreply, port}
  end

  @impl true
  def handle_cast({:cast, pid, payload}, port) do
    conn_id = ProcReg.query_id(pid)
    cmd = Frame.serialize(:ps_cast, conn_id, payload)
    Port.command(port, cmd)
    {:noreply, port}
  end

  @impl true
  def handle_info({_, {:data, data}}, port) do
    {type, chan_id, payload} = Frame.deserialize(data)
    pid = ProcReg.query_pid(chan_id)
    case type do
      :ps_call->
        tag = CallReg.query_calltag(pid)
        GenServer.reply({pid, tag}, payload)
      :ps_cast->
        GenServer.cast(pid, payload)
      :ps_monitor->
        Process.monitor(pid)
    end
    {:noreply, port}
  end

  @impl true
  def handle_info({:DOWN, _, :process, pid, _reason}, port) do
    conn_id = ProcReg.query_id(pid)
    cmd = Frame.serialize(:ps_down, conn_id, <<>>)
    Port.command(port, cmd)
    {:noreply, port}
  end
end
