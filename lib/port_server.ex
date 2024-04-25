defmodule PortServer do
  @moduledoc """
  The main module exposing the public API of PortServer

  PortServer is a standard GenServer implementation.
  It can be started manually or through a supervision tree.
  You can interact with it through `call/3` or `cast/3`.
  """
  alias PortServer.Server

  @type command :: {String.t(), [String.t()], Keyword.t()}

  @valid_options ~w(dir env start_timeout)a

  @doc """
  Start PortServer by running a command.

  The command is consists of three parts: {"command", "arguments", "options"}

  ```elixir
  #
  {:ok, pid} = PortServer.start({"node", ["./index.js"], [dir: "../"]})
  ```

  Available options:

    * `:dir` - current working directory.

    * `:env` - environment variables.

    * `:start_timeout` - Port server must start within the specified time.
      Otherwise, it will be considered as a initialization failure.

  """
  @spec start(command(), GenServer.options()) :: GenServer.on_start()
  def start(command, gs_options \\ []) do
    with {:ok, command} <- validate_command(command) do
      GenServer.start(Server, command, gs_options)
    end
  end

  @doc """
  Similar to `start/2` except it will call `GenServer.start_link/3` instead of
  `GenServer.start/3`
  """
  @spec start_link(command(), GenServer.options()) :: GenServer.on_start()
  def start_link(command, gs_options \\ []) do
    with {:ok, command} <- validate_command(command) do
      GenServer.start_link(Server, command, gs_options)
    end
  end

  @doc """
  Makes a synchronous call to the `server` and waits for its reply.

  Similar to `GenServer.call/3`

  `msg` is the handler name to be called.

  `payload` can be any term the can be jsonized.

  ```elixir
  reply = PortServer.call(pid, "func", %{
      p1=> "hello",
      p2=> 100
    })
  ```

  """
  @spec call(GenServer.server(), String.t(), term(), timeout()) :: term()
  def call(server, msg, payload \\ nil, timeout \\ 5000) do
    payload = Jason.encode!(payload)

    GenServer.call(server, {:call, msg, payload}, timeout)
    |> Jason.decode!()
  end

  @doc """
  Casts a request to the `server` without waiting for a response.

  Similar to `GenServer.cast/2`

  `msg` is the handler name to be cast.

  `payload` can be any term the can be jsonized.

  ```elixir
  PortServer.cast(pid, "event", %{
      p1=> "hello",
      p2=> 100
    })
  ```

  """
  @spec cast(GenServer.server(), String.t(), term()) :: term()
  def cast(server, msg, payload \\ nil) do
    payload = Jason.encode!(payload)
    GenServer.cast(server, {:cast, self(), msg, payload})
  end

  defp validate_command(command) do
    case command do
      {prog, args, options} ->
        case Keyword.split(options, @valid_options) do
          {_, []} ->
            {:ok, {prog, args, options}}

          {_, illegal_options} ->
            {:error, {:invalid_options, illegal_options}}
        end

      _ ->
        {:error, {:invalid_command, command}}
    end
  end
end
