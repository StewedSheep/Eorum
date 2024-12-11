defmodule Proj.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProjWeb.Telemetry,
      Proj.Repo,
      {DNSCluster, query: Application.get_env(:proj, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Proj.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Proj.Finch},
      ProjWeb.Presence,
      TwMerge.Cache,
      # Start a worker by calling: Proj.Worker.start_link(arg)
      # {Proj.Worker, arg},
      # Start to serve requests, typically the last entry
      ProjWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proj.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ProjWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
