defmodule Whoami.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WhoamiWeb.Telemetry,
      Whoami.Repo,
      {DNSCluster, query: Application.get_env(:whoami, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Whoami.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Whoami.Finch},
      # Start a worker by calling: Whoami.Worker.start_link(arg)
      # {Whoami.Worker, arg},
      # Start to serve requests, typically the last entry
      WhoamiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Whoami.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhoamiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
