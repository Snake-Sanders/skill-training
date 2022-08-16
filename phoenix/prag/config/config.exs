# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :prag,
  ecto_repos: [Prag.Repo]

# Configures the endpoint
config :prag, PragWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PragWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Prag.PubSub,
  live_view: [signing_salt: "pQFHQIK5"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :prag, Prag.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Style pipeline
# The output of DartSass is used as the input to the Tailwind CLI.
# That’ll be the second stage of the CSS build process.

# 1st stage:
# This uses your assets/css/app.scss as the input file and drops the compiled
# CSS into the priv/static/assets/app.tailwind.css file. That’ll be the first
# stage of the CSS build process.
config :dart_sass,
  version: "1.49.11",
  default: [
    args: ~w(css/app.scss ../priv/static/assets/app.tailwind.css),
    cd: Path.expand("../assets", __DIR__)
  ]

# 2nd stage:
# Uses the intermediate priv/static/assets/app.tailwind.css file as its input
# and spit out the final CSS in /priv/static/assets/app.css.
# Use TailwindCss for style https://tailwindcss.com/docs/guides/phoenix
config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=../priv/static/assets/app.tailwind.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
