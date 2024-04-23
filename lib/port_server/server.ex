defmodule PortServer.Server do
  @moduledoc """
  """
  alias PortServer.Port
  alias PortServer.Frame
  use GenServer

  @impl true
  def init({prog, args, options}) do
    port = Port.open(prog, args, options)
    {:ok, port}
  end

  @impl true
  def handle_call({:call, payload}, {pid, tag}, port) do
    pid = :erlang.term_to_binary(pid)
    tag = :erlang.term_to_binary(tag)
    frame = Frame.serialize(0, [pid, tag, payload])
    Port.command(port, frame)
    {:noreply, port}
  end

  @impl true
  def handle_cast({:cast, frame}, port) do
    Port.command(port, frame)
    {:noreply, port}
  end

  @impl true
  def handle_info({_, {:data, data}}, port) do
    frame = Frame.deserialize(data)

    case frame do
      {0, [pid, tag, payload]} ->
        GenServer.reply({pid, tag}, payload)

      {1, [pid, payload]} ->
        GenServer.cast(pid, payload)

      {2, [pid]} ->
        Process.monitor(pid)
    end

    {:noreply, port}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, port) do
    frame = Frame.serialize(2, [pid])
    Port.command(port, frame)
    {:noreply, port}
  end

  @impl true
  def handle_info({_port, {:exit_status, _status}}, port) do
    {:stop, :error, port}
  end
end
