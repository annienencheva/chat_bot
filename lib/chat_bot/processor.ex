defmodule ChatBot.Processor do
  @moduledoc false

  alias ChatBot.Ai
  alias ChatBot.Whippy.Messenger

  @doc """
  The function will cache the message in the ETS table and then process it by
  finding the conversation history, sending it to the AI model and then sending
  the response back to the contact via Whippy's API.
  """
  def handle_message(message) do
    message
    |> atomize()
    |> cache_message()
    |> do_process()
  end

  defp do_process(%{direction: "OUTBOUND"}) do
    :ok
  end

  defp do_process(message) do
    with {:ok, messages} <- fetch_messages(message.conversation_id),
         {:ok, response} <- Ai.Communicator.send(messages) do
      phone = message.from
      reply = Enum.at(response.choices, 0)["message"]["content"]

      if should_send_reply?(reply) do
        Messenger.send_message(phone, reply)
      end
    end
  end

  defp cache_message(message) do
    case fetch_messages(message.conversation_id) do
      {:ok, messages} ->
        write_messages(message.conversation_id, [message | messages])

      {:error, :not_found} ->
        write_messages(message.conversation_id, [message])
    end

    message
  end

  defp fetch_messages(conversation_id) do
    case :ets.lookup(:conversation_messages, conversation_id) do
      [{_, messages}] -> {:ok, messages}
      [] -> {:error, :not_found}
    end
  end

  defp write_messages(conversation_id, messages) do
    :ets.insert(:conversation_messages, {conversation_id, messages})
  end

  defp atomize(message) do
    Map.new(message, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp should_send_reply?(reply) do
    reply != "END"
  end
end
