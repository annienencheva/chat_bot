defmodule ChatBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # ETS table that will store the conversation history
    # It will be populated on every message.created event received from Whippy
    :ets.new(:conversation_messages, [:named_table, :public])

    children = [
      # Start the Telemetry supervisor
      ChatBotWeb.Telemetry,
      # Start the Ecto repository
      ChatBot.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ChatBot.PubSub},
      # Start Finch
      {Finch, name: ChatBot.Finch},
      # Start the Endpoint (http/https)
      ChatBotWeb.Endpoint
      # Start a worker by calling: ChatBot.Worker.start_link(arg)
      # {ChatBot.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatBot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ChatBotWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
