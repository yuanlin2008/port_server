defmodule PortServer.Application do
  use Application
  @impl true
  def start(_type, _args) do
    children = [
      PortServer.CallTable
    ]
    opts = [strategy: :one_for_one, name: PortServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
