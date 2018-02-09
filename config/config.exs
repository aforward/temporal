use Mix.Config

if Mix.env() == :dev do
  config :mix_test_watch,
    setup_tasks: [],
    ansi_enabled: :ignore,
    clear: true
end
