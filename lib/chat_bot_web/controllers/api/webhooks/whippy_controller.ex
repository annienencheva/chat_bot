defmodule ChatBotWeb.Api.Webhooks.WhippyController do
  use ChatBotWeb, :controller

  alias ChatBot.Processor

  action_fallback ChatBotWeb.FallbackController

  def message(conn, %{"event" => "message.created", "data" => data}) do
    Processor.handle_message(data)

    conn
    |> put_status(200)
    |> json(%{response: "Success"})
  end

  # Ignore other events for now
  def message(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{response: "Success"})
  end
end
