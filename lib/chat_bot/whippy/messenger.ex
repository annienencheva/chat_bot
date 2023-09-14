defmodule ChatBot.Whippy.Messenger do
  @moduledoc """
  This module is responsible for communicating with Whippy's Messaging API.
  """

  @sms_path "/v1/messaging/sms"
  @conversation_path "/v1/conversations/"

  @spec send_message(String.t(), String.t()) :: {:ok, map()} | {:error, any}
  def send_message(to, body) do
    (base_url() <> @sms_path)
    |> HTTPoison.post(payload(to, body), headers())
    |> handle_response()
  end

  @spec fetch_messages(String.t()) :: {:ok, list()} | {:error, any}
  def fetch_messages(conversation_id) do
    (base_url() <> @conversation_path <> conversation_id)
    |> HTTPoison.get(headers())
    |> handle_response()
    |> case do
      {:ok, %{"data" => %{"messages" => messages}}} -> {:ok, messages}
      {:error, reason} -> {:error, reason}
    end
  end

  defp payload(to, body) do
    %{
      attachments: [],
      body: body,
      from: from_phone(),
      to: to
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
      {:ok, %{body: body, status_code: code}} when code in 200..299 -> {:ok, Jason.decode!(body)}
      {:ok, %{body: body, status_code: _code}} -> {:error, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end
