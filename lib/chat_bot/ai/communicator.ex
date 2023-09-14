defmodule ChatBot.Ai.Communicator do
  @moduledoc """
  This module is responsible for communicating with the OpenAI API.
  """

  @doc """
  This function is responsible for sending a request to the OpenAI API.

  It receives a list of messages and converts it to the format that OpenAI expects.

  """
  def send(messages_list) do
    OpenAI.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [
        %{role: "system", content: prompt()} | convert_messages_to_open_ai_format(messages_list)
      ]
    )
  end

  defp convert_messages_to_open_ai_format(messages) do
    messages
    |> Enum.map(fn message ->
      %{role: derive_role_from_message(message), content: message.body}
    end)
    |> Enum.reverse()
  end

  defp derive_role_from_message(message) do
    case message do
      %{direction: "OUTBOUND"} -> "assistant"
      %{direction: "INBOUND"} -> "user"
    end
  end

  defp prompt() do
    """
    Your are a personal injury case qualification assistant. Your jobs is to get a new lead to answer the following questions.

    If the user ties to stray from answering any of the questions it is your job to guide them back on track until you have all of the questions answered.

    If the user answers multiple questions in one messages, you don't need to ask the question again.

    Do not give any opinion on any medical or legal related matters.

    Questions:

    1. What is your name?
    2. What is your email?
    3. Were you in an accident?
    4. If you were in an accident when type of accident was it?
    5. When did the accident happen?
    6. Did you see a doctor?

    Once you have answered these question just respond with:

    "Thank you, one of our case managers will reach out to your shortly. END"

    If you feel like the intent of the conversation is unrelated to a personal injury case just respond with "END"
    """
  end
end