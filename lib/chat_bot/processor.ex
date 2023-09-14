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

  defp do_process(%{conversation_id: conversation_id, from: reply_to} = message) do
    with {:ok, :process} <- validate_message_sent_to_bot_phone(message),
         {:ok, messages, false = _resolved?} <- fetch_history(conversation_id),
         {:ok, %{choices: [%{"message" => %{"content" => reply}} | _]}} <-
           Ai.Communicator.send(messages) do
      # Send back a reply in case AI model returns a response different than END
      case parse_reply(reply) do
        {reply, :continue} ->
          Messenger.send_message(reply_to, reply)

        {"", :end} ->
          mark_conversation_as_resolved(conversation_id)

        {reply, :end} ->
          Messenger.send_message(reply_to, reply)
          mark_conversation_as_resolved(message.conversation_id)
      end
    end
  end

  defp atomize(message) do
    Map.new(message, fn
      {k, v} when is_binary(k) -> {String.to_atom(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp parse_reply(reply) do
    case String.split(reply, "END") do
      [reply, _end] -> {reply, :end}
      [reply] -> {reply, :continue}
    end
  end

  defp validate_message_sent_to_bot_phone(%{to: location_phone}) do
    if location_phone == System.get_env("WHIPPY_FROM_PHONE") do
      {:ok, :process}
    else
      {:error, :not_sent_to_bot_phone}
    end
  end

  ########################
  ###  ETS Operations  ###
  ########################

  defp cache_message(message) do
    with {:error, :not_found} <- fetch_history(message.conversation_id),
         {:error, _reason} <- Messenger.fetch_messages(message.conversation_id) do
      # if not found in ETS and not found in Whippy, cache only the new message in ETS
      write_messages(message.conversation_id, [message], false)
    else
      # if fetched from ETS, append the new message to the list of messages
      {:ok, messages, resolved?} ->
        write_messages(message.conversation_id, [message | messages], resolved?)

      # if fetched from Whippy, atomize and write the messages to ETS
      {:ok, messages} ->
        write_messages(message.conversation_id, Enum.map(messages, &atomize/1), false)
    end

    message
  end

  defp fetch_history(conversation_id) do
    case :ets.lookup(:conversation_messages, conversation_id) do
      [{_, %{messages: messages, resolved: resolved}}] -> {:ok, messages, resolved}
      [] -> {:error, :not_found}
    end
  end

  defp write_messages(conversation_id, messages, is_conversation_resolved?) do
    :ets.insert(
      :conversation_messages,
      {conversation_id, %{resolved: is_conversation_resolved?, messages: messages}}
    )
  end

  defp mark_conversation_as_resolved(conversation_id) do
    :ets.insert(:conversation_messages, {conversation_id, %{resolved: true, messages: []}})
  end
end
