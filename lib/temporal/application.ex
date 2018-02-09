defmodule Temporal.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Temporal.Downloader, []),
      worker(Temporal.Scheduler, []),
      worker(Temporal.Callback, [])
    ]

    opts = [strategy: :one_for_one, name: Temporal.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
