defmodule ChatBotWeb.Api.Webhooks.WhippyController do
  use ChatBotWeb, :controller

  alias Chatbot.Processor

  def message(conn, %{"event" => "message.created", "data" => data}) do
    ChatBot.Processor.handle_message(data)

    conn
    |> put_status(200)
    |> json(%{response: "Success"})
  end

  # Ignore other events for now
  def message(conn, params) do
    conn
    |> put_status(200)
    |> json(%{response: "Success"})
  end
end
