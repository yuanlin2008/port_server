defmodule PortServer.Port do
  @moduledoc """
  """
  @spec open(String.t(), [String.t()], Keyword.t()) :: port()
  def open(prog, args, options) do
    Port.open(
      {:spawn_executable, find_executable(prog)},
      get_port_options(args, options)
    )
  end

  defdelegate command(port, data, options \\ []), to: Port

  defp find_executable(prog) do
    cond do
      File.exists?(prog) ->
        Path.absname(prog)

      exe = :os.find_executable(:erlang.binary_to_list(prog)) ->
        List.to_string(exe)

      true ->
        raise ArgumentError, "Command not found: #{prog}"
    end
  end

  @port_options [
    :binary,
    {:packet, 4},
    :exit_status,
    :nouse_stdio
  ]

  @valid_options ~w(dir env)a

  defp get_port_options(args, options) do
    options = validate_options(options)

    @port_options ++
      [{:args, args}] ++
      if(dir = options[:dir], do: [cd: dir], else: []) ++
      if env = options[:env], do: [env: env], else: []
  end

  defp validate_options(options) do
    case Keyword.split(options, @valid_options) do
      {options, []} ->
        options

      {_, illegal_options} ->
        raise ArgumentError,
              "Unsupported key(s) options: #{inspect(Keyword.keys(illegal_options))}"
    end
  end
end
