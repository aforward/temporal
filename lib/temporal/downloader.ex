defmodule Temporal.Downloader do
  use GenServer

  alias GenServer, as: GS
  alias Temporal.Downloader, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)
  end

  def clear(), do: GS.call(W, :clear)
  def files(), do: GS.call(W, {:files, nil})
  def files(n), do: GS.call(W, {:files, n})
  def now(params), do: GS.call(W, {:download, params})
  def later(params), do: GS.cast(W, {:download, params})

  ### Server Callbacks

  def init(_) do
    {:ok, zero_state()}
  end

  def handle_call(:clear, _from, state) do
    {:reply, state, zero_state()}
  end

  def handle_call({:files, nil}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:files, n}, _from, state) do
    {:reply, Enum.take(state, n), state}
  end

  def handle_call({:download, params}, _from, state) do
    {file, new_state} = download(params, state)
    {:reply, file, new_state}
  end

  def handle_cast({:download, params}, state) do
    {_, new_state} = download(params, state)
    {:noreply, new_state}
  end

  defp download(params, state) do
    params
    |> Temporal.Fetch.go()
    |> update_state(params, state)
  end

  defp update_state({:ok, file}, params, old_state) do
    Temporal.Callback.callback(params, file)
    {file, [file | old_state]}
  end

  defp update_state({:skip, file}, _params, state), do: {file, state}

  defp zero_state, do: []
end
