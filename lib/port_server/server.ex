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
  def handle_info(_msg, port) do
    {:noreply, port}
  end
end
