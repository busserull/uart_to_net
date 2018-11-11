# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :uart_to_net,
  namespace: UT,
  ecto_repos: [UT.Repo]

# Configures the endpoint
config :uart_to_net, UTWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KYWUFFmSXeYDmyDLLOB+G9/WL46UraNXMzJp5VQxY9AdhlDb+oeuMOtrpMLBB2fE",
  render_errors: [view: UTWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: UT.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
