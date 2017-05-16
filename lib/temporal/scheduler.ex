defmodule Temporal.Scheduler do
  use GenServer

  alias GenServer, as: GS
  alias Temporal.Scheduler, as: W

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)
  end

  def now(params), do: GS.call(W, {:schedule, params |> Temporal.normalize})
  def later(params), do: GS.cast(W, {:schedule, params |> Temporal.normalize})

  ### Server Callbacks

  def init(_) do
    schedule_work()
    {:ok, zero_state()}
  end

  def handle_call({:schedule, params}, _from, state) do
    new_state = update_state(params, state)
    process_work(params)
    {:reply, elem(new_state, 0), new_state}
  end

  def handle_cast({:schedule, params}, state) do
    {:noreply, update_state(params, state)}
  end

  def handle_info(:work, state) do
    state
    |> elem(1)
    |> process_work
    {:noreply, state}
  end

  defp process_work(schedules) when is_list(schedules), do: Enum.each(schedules, &process_work/1)
  defp process_work(schedule) when is_map(schedule), do: Temporal.Downloader.now(schedule)

  defp schedule_work() do
    Process.send_after(self(), :work, 11 * 60 * 1000) # 11 minutes
  end

  defp update_state({:error, :timeout}, state), do: state
  defp update_state(schedule, {num, schedules}), do: {num + 1, [schedule | schedules]}

  defp zero_state, do: {0, []}

end
