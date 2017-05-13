defmodule Temporal do
  @moduledoc"""
  Documentation for Temporal.
  """
  defdelegate files, to: Temporal.Downloader
  defdelegate files(n), to: Temporal.Downloader
  defdelegate download_now(params), to: Temporal.Downloader, as: :now
  defdelegate download_later(params), to: Temporal.Downloader, as: :later
  defdelegate schedule_now(params), to: Temporal.Scheduler, as: :now
  defdelegate schedule_later(params), to: Temporal.Scheduler, as: :later

end
