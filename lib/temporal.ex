defmodule Temporal do
  @moduledoc"""
  Documentation for Temporal.
  """
  defdelegate files, to: Temporal.Worker
  defdelegate files(n), to: Temporal.Worker
  defdelegate download_now(params), to: Temporal.Worker
  defdelegate download_later(params), to: Temporal.Worker
end
