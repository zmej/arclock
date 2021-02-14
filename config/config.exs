# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :arclock, ArclockWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "295wAKVXpNE11ao8uqObyDr8B2r1OrMD7GyTPWtdr83zGDjhdOK77z3dECloWiEg",
  render_errors: [view: ArclockWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Arclock.PubSub,
  live_view: [signing_salt: "IGAUuweBqJJujK7aVENi+/9oh9PO6mgp"]

config :arclock,
  # pin numbers for orders of magnitude
  # GPIO numbering, not physical numbering.
  ones: %{a: 4, b: 17, c: 27, d: 22}, 
  tens: %{a: 10, b: 9, c: 11, d: 5},
  hundreds: %{a: 6, b: 13, c: 19, d: 26},

  buzzer_pin: 21,

  # 7 segment decoder truth table
  digits: %{
    0 => %{a: 0, b: 0, c: 0, d: 0},
    1 => %{a: 0, b: 0, c: 0, d: 1},
    2 => %{a: 0, b: 0, c: 1, d: 0},
    3 => %{a: 0, b: 0, c: 1, d: 1},
    4 => %{a: 0, b: 1, c: 0, d: 0},
    5 => %{a: 0, b: 1, c: 0, d: 1},
    6 => %{a: 0, b: 1, c: 0, d: 0},
    7 => %{a: 0, b: 1, c: 1, d: 1},
    8 => %{a: 1, b: 0, c: 0, d: 0},
    9 => %{a: 1, b: 0, c: 0, d: 1},
    :a => %{a: 1, b: 0, c: 1, d: 0},
    :b => %{a: 1, b: 0, c: 1, d: 1},
    :c => %{a: 1, b: 1, c: 0, d: 0},
    :d => %{a: 1, b: 1, c: 0, d: 1},
    :dash => %{a: 1, b: 1, c: 1, d: 1},
    :blank => %{a: 1, b: 1, c: 1, d: 1}
  }

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
