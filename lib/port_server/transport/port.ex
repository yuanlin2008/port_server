defmodule PortServer.Transport.Port do
  @behaviour PortServer.Transport

  @type options :: {Port.name(), list()}

  @port_options [
    :binary,
    {:packet, 4},
    :exit_status,
    :nouse_stdio
  ]

  @impl true
  def init({name, options}) do
    Port.open(name, @port_options ++ options)
  end

  @impl true
  def send(data, port) do
    Port.command(port, data)
  end

  @impl true
  def recv(port, msg) do
    case msg do
      {^port, {:data, data}} ->
        data

      {:EXIT, ^port, reason} ->
        {:error, reason}
    end
  end
end
