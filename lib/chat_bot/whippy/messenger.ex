defmodule ChatBot.Whippy.Messenger do
  @moduledoc """
  This module is responsible for communicating with Whippy's Messaging API.
  """

  @sms_path "/v1/messaging/sms"

  def send(body) do
    "#{base_url()}#{@sms_path}"
    |> HTTPoison.post(payload(body), headers())
    |> handle_response()
  end

  defp payload(body) do
    %{
      attachments: [],
      body: body,
      from: from_phone(),
      to: "+14155552671"
    }
    |> Jason.encode!()
  end

  defp headers() do
    [
      {"Content-Type", "application/json"},
      {"Accept", "application/json"},
      {"x-whippy-key", System.get_env("WHIPPY_API_KEY")}
    ]
  end

  defp base_url, do: System.get_env("WHIPPY_BASE_URL")
  defp from_phone, do: System.get_env("WHIPPY_FROM_PHONE")

  defp handle_response(response) do
    case response do
      {:ok, %{body: body, status_code: 201}} -> {:ok, Jason.decode!(body)}
      {:ok, %{body: body, status_code: _code}} -> {:error, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end
