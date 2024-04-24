defmodule PortServer.Port do
  @moduledoc false
  @spec open(String.t(), [String.t()], Keyword.t()) :: {:ok, port()} | {:error, term()}
  def open(prog, args, options) do
    with {:ok, exe} <- find_executable(prog) do
      port =
        Port.open(
          {:spawn_executable, exe},
          get_port_options(args, options)
        )

      {:ok, port}
    end
  end

  defdelegate command(port, data, options \\ []), to: Port

  defp find_executable(prog) do
    cond do
      File.exists?(prog) ->
        {:ok, Path.absname(prog)}

      exe = :os.find_executable(:erlang.binary_to_list(prog)) ->
        {:ok, List.to_string(exe)}

      true ->
        {:stop, {:cmd_not_found, prog}}
    end
  end

  @port_options [
    :binary,
    {:packet, 4},
    :exit_status,
    :nouse_stdio
  ]

  defp get_port_options(args, options) do
    @port_options ++
      [{:args, args}] ++
      if(dir = options[:dir], do: [cd: dir], else: []) ++
      if env = options[:env], do: [env: env], else: []
  end
end
