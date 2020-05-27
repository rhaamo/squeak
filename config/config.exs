# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :squeak,
  ecto_repos: [Squeak.Repo]

# Configures the endpoint
config :squeak, SqueakWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZQCtokLsXDUgMQpezzzpyG26Ju/OKijVAyZ6EaeJwB/WyLR263FHwVCurssK+xmP",
  render_errors: [view: SqueakWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Squeak.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [signing_salt: "AYg9mlBc"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :squeak, :pow,
  user: Squeak.Users.User,
  repo: Squeak.Repo,
  web_module: SqueakWeb,
  extensions: [PowResetPassword, PowEmailConfirmation, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: SqueakWeb.Pow.Mailer,
  web_mailer_module: SqueakWeb

config :squeak, SqueakWeb.Pow.Mailer,
  adapter: Swoosh.Adapters.Sendmail

config :squeak, :mailer,
  from_name: "Otter",
  from: "squeak@example.com"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
