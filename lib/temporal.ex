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

  def normalize(params), do: default_opts() |> Map.merge(params)
  def default_opts() do
    %{basedir:  Application.get_env(:temporal, :basedir, "/tmp"),
      frequency: Application.get_env(:temporal, :frequency, :daily),
      method: Application.get_env(:temporal, :method, :get),
      force: Application.get_env(:temporal, :force, false)}
  end

end
