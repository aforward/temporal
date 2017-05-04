defmodule Temporal.Worker do
  use GenServer

  alias GenServer, as: GS

  ### Public API

  def start_link() do
    {:ok, _pid} = GS.start_link(__MODULE__, [], name: __MODULE__)
  end

  ### Server Callbacks

  def init(_) do
    {:ok, zero_state()}
  end

  defp zero_state, do: :ok

end
