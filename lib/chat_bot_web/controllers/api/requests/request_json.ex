defmodule ChatBotWeb.Api.RequestJSON do
  alias ChatBot.Requests.Request

  @doc """
  Renders a list of requests.
  """
  def index(%{requests: requests}) do
    %{data: for(request <- requests, do: data(request))}
  end

  @doc """
  Renders a single request.
  """
  def show(%{request: request}) do
    %{data: data(request)}
  end

  defp data(%Request{} = request) do
    %{
      id: request.id,
      url: request.url,
      status_code: request.status_code,
      body: request.body,
      response: request.response,
      inserted_at: request.inserted_at,
      updated_at: request.updated_at
    }
  end
end
