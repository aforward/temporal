defmodule Temporal.Callback do
  use GenServer

  alias GenServer, as: GS
  alias Temporal.Callback, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)
  end

  def clear(), do: GS.call(W, :clear)
  def register(fun), do: GS.cast(W, {:register, fun})
  def callback(params, filename), do: GS.cast(W, {:callback, params, filename})

  ### Server Callbacks

  def init(_) do
    {:ok, zero_state()}
  end

  def handle_call(:clear, _from, state) do
    {:reply, state, zero_state()}
  end

  def handle_cast({:register, fun}, state) do
    {:noreply, [fun | state]}
  end

  def handle_cast({:callback, params, filename}, state) do
    Enum.each(state, fn fun -> fun.(params, filename) end)
    {:noreply, state}
  end

  defp zero_state, do: []
end
