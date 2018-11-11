use Mix.Config

config :uart_to_net, interface: "ttyACM0"
config :uart_to_net, speed: 9600

config :uart_to_net, UTWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
                    cd: Path.expand("../assets", __DIR__)]]

config :uart_to_net, UTWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/uart_to_net_web/views/.*(ex)$},
      ~r{lib/uart_to_net_web/templates/.*(eex)$}
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :uart_to_net, UT.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "uart_to_net_dev",
  hostname: "localhost",
  pool_size: 10
