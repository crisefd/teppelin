# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :teppelin,
  ecto_repos: [Teppelin.Repo]

# Configures the endpoint
config :teppelin, TeppelinWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "a3GsLCrrxP4AcOxCENkq93NXZhzsMM7fb867YdMdKb1bKJuR7rF12R/FsyQx2/8X",
  render_errors: [view: TeppelinWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Teppelin.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Ttwich API configuraiton

config :teppelin,
        twitch_base_url: "https://api.twitch.tv/kraken",
        twitch_client_id: "3arfvc5f6s5s8j1k07rlvoo3a1q3h7",
        twitch_secret_key: "rcd83bls8hdxbvudm05rpldwtkent9"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
