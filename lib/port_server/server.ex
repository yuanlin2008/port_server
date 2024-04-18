defmodule PortServer.Server do
  @moduledoc """
  """
  use GenServer

  @impl true
  def init(options) do
    # defer init
    {:ok, options, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {transport, options}) do
    port = transport.init(options)
    state = {transport, port}
    {:noreply, state}
  end

  @impl true
  def handle_call({:send, frame}, _, {transport, port} = state) do
    transport.send(frame, port)
    {:noreply, state}
  end

  # @impl true
  # def handle_call({:call, payload}, from, state) do
  #   id = state.id + 1
  #   iodata = Frame.serialize({:call, state.id, payload})
  #   {:noreply, %{state | id: id}}
  # end
end
