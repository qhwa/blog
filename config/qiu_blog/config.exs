# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :qiu_blog, :metadata,
  title: "Q",
  description: "A site of a software/hardware/life hacker.",
  twitter_site: "qhwa",
  twitter_card_type: "summary_large_image"

# Configures the endpoint
config :qiu_blog, QiuBlogWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: QiuBlogWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: QiuBlog.PubSub,
  live_view: [signing_salt: "419a8oxA"],
  force_ssl: [rewrite_on: [:x_forwarded_proto], hsts: true]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.17",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --loader:.png=file --public-path=/assets --loader:.woff2=file),
    cd: Path.expand("../../apps/qiu_blog/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../../deps", __DIR__)}
  ]

# Configures the mailer.
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :qiu_blog, QiuBlog.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
