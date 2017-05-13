defmodule Temporal.Worker do
  use GenServer

  alias GenServer, as: GS
  alias Temporal.Worker, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)
  end

  def files(), do: GS.call(W, {:files, nil})
  def files(n), do: GS.call(W, {:files, n})
  def download_now(params), do: GS.call(W, {:download, params})
  def download_later(params), do: GS.cast(W, {:download, params})

  ### Server Callbacks

  def init(_) do
    {:ok, zero_state()}
  end

  def handle_call({:download, params}, _from, state) do
    {_, file} = Temporal.Fetch.go(params)
    {:reply, file, [file | state]}
  end

  def handle_call({:files, nil}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:files, n}, _from, state) do
    {:reply, Enum.take(state, n), state}
  end

  def handle_cast({:download, params}, state) do
    {_, file} = Temporal.Fetch.go(params)
    {:noreply, [file | state]}
  end

  defp zero_state, do: []

end
