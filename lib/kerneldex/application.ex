defmodule Kerneldex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      KerneldexWeb.Telemetry,
      Kerneldex.Repo,
      {DNSCluster, query: Application.get_env(:kerneldex, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Kerneldex.PubSub},
      # Start a worker by calling: Kerneldex.Worker.start_link(arg)
      # {Kerneldex.Worker, arg},
      # Start to serve requests, typically the last entry
      KerneldexWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Kerneldex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KerneldexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
