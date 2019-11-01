# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :teppelin, TeppelinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MY_SECRET_KEY",
  live_view: [signing_salt: "8E1OPYds"],
  render_errors: [view: TeppelinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Teppelin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Ttwich API configuraiton

config :teppelin,
        twitch_base_url: "https://api.twitch.tv/kraken",
        twitch_client_id: "3arfvc5f6s5s8j1k07rlvoo3a1q3h7",
        api_version: "application/vnd.twitchtv.v5+json",
        twitch_secret_key: "MY_TWITCH_SECRET_KEY"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
