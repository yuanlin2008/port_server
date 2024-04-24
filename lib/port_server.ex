defmodule PortServer do
  @moduledoc """
  Documentation for `PortServer`.
  """
  alias PortServer.Server

  @typedoc """
  Options to be passed to start_link.
  """
  @type command ::
          {String.t()}
          | {String.t(), [String.t()]}
          | {String.t(), [String.t()], Keyword.t()}

  @valid_options ~w(dir env start_timeout)a

  @doc """
  """
  @spec start(command(), GenServer.options()) :: GenServer.on_start()
  def start(command, gs_options \\ []) do
    with {:ok, command} <- validate_command(command) do
      GenServer.start(Server, command, gs_options)
    end
  end

  @doc """
  """
  @spec start_link(command(), GenServer.options()) :: GenServer.on_start()
  def start_link(command, gs_options \\ []) do
    with {:ok, command} <- validate_command(command) do
      GenServer.start_link(Server, command, gs_options)
    end
  end

  @doc """
  """
  @spec call(GenServer.server(), term(), timeout()) :: term()
  def call(server, payload, timeout \\ 5000) do
    payload = Jason.encode!(payload)

    GenServer.call(server, {:call, payload}, timeout)
    |> Jason.decode!()
  end

  @spec cast(GenServer.server(), term()) :: term()
  def cast(server, payload) do
    payload = Jason.encode!(payload)
    GenServer.cast(server, {:cast, self(), payload})
  end

  defp validate_command(command) do
    case command do
      {prog} ->
        {:ok, {prog, [], []}}

      {prog, args} ->
        {:ok, {prog, args, []}}

      {prog, args, options} ->
        case Keyword.split(options, @valid_options) do
          {_, []} ->
            {:ok, {prog, args, options}}

          {_, illegal_options} ->
            {:error, {:invalid_options, illegal_options}}
        end

      _ ->
        :ok
    end
  end
end
