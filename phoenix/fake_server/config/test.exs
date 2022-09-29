import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :fake_server, FakeServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Nofa16ItY8a9cGioC6/e13m9tmGuje5VqumAbZY7B6PybsHtJ2B6ljmH7BhKibbZ",
  server: false

# In test we don't send emails.
config :fake_server, FakeServer.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
