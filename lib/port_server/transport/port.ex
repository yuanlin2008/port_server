defmodule PortServer.Transport.Port do
  @behaviour PortServer.Transport

  @type options :: {:port, Port.name(), list()}

  @port_options [
    :binary,
    {:packet, 4},
    :exit_status,
    :nouse_stdio
  ]

  @impl true
  def init({:port, name, options}) do
    Port.open(name, @port_options ++ options)
  end

  @impl true
  def send(transport, data) do
    Port.command(transport, data)
  end
end
