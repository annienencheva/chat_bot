defmodule ChatBot.Ai.Communicator do
  @moduledoc """
  This module is responsible for communicating with the OpenAI API.
  """

  @doc """
  This function is responsible for sending a request to the OpenAI API.
  """
  def send(user_message) do
    OpenAI.chat_completion(
      model: "gpt-3.5-turbo",
      messages: [
        %{role: "system", content: "You are a helpful assistant."},
        %{role: "user", content: "Who won the world series in 2020?"},
        %{role: "assistant", content: "The Los Angeles Dodgers won the World Series in 2020."},
        %{role: "user", content: "Where was it played?"}
      ]
    )
  end
end
