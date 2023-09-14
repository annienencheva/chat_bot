defmodule ChatBot.RequestsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatBot.Requests` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
    {:ok, request} =
      attrs
      |> Enum.into(%{
        body: %{},
        response: %{},
        status_code: 42,
        url: "some url"
      })
      |> ChatBot.Requests.create_request()

    request
  end
end
