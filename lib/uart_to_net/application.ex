defmodule UT.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    serial_options = [
      interface: Application.get_env(:uart_to_net, :interface),
      speed: Application.get_env(:uart_to_net, :speed)
    ]

    children = [
      supervisor(UTWeb.Endpoint, []),
      {UT.Serial, serial_options}
    ]

    opts = [strategy: :one_for_one, name: UT.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    UTWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
