defmodule ChatBotWeb.Api.RequestController do
  use ChatBotWeb, :controller

  alias ChatBot.Requests
  alias ChatBot.Requests.Request

  action_fallback ChatBotWeb.FallbackController

  def index(conn, _params) do
    requests = Requests.list_requests()
    render(conn, :index, requests: requests)
  end

  def show(conn, %{"id" => id}) do
    request = Requests.get_request!(id)
    render(conn, :show, request: request)
  end

  def delete(conn, %{"id" => id}) do
    request = Requests.get_request!(id)

    with {:ok, %Request{}} <- Requests.delete_request(request) do
      send_resp(conn, :no_content, "")
    end
  end
end
