defmodule PortServer.Server do
  @moduledoc false

  alias PortServer.Port
  alias PortServer.Frame
  use GenServer

  @impl true
  def init({prog, args, options}) do
    with {:ok, port} <- Port.open(prog, args, options),
         :ok <- wait_start(port, options) do
      {:ok, port}
    end
  end

  @impl true
  def handle_call({:call, payload}, {pid, tag}, port) do
    Port.command(port, Frame.serialize(["call", pid, tag, payload]))
    {:noreply, port}
  end

  @impl true
  def handle_cast({:cast, pid, payload}, port) do
    Port.command(port, Frame.serialize(["cast", pid, payload]))
    {:noreply, port}
  end

  @impl true
  def handle_info({_, {:data, data}}, port) do
    frame = Frame.deserialize(data)

    case frame do
      ["reply", pid, tag, payload] ->
        GenServer.reply({pid, tag}, payload)

      ["cast", pid, payload] ->
        # todo: optimization.
        spawn(fn ->
          GenServer.cast(pid, Jason.decode!(payload))
        end)

      ["monitor", pid] ->
        Process.monitor(pid)
    end

    {:noreply, port}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, port) do
    Port.command(port, Frame.serialize(["down", pid]))
    {:noreply, port}
  end

  @impl true
  def handle_info({_port, {:exit_status, status}}, port) do
    {:stop, {:exit_status, status}, port}
  end

  defp wait_start(port, options) do
    timeout = Keyword.get(options, :start_timeout, 5000)

    receive do
      {^port, {:exit_status, status}} ->
        {:stop, {:exit_status, status}}

      {^port, {:data, data}} ->
        case Frame.deserialize(data) do
          ["started"] -> :ok
          _ -> {:stop, :invalid_startup}
        end
    after
      timeout -> {:stop, :start_timeout}
    end
  end
end
