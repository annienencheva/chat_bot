defmodule ChatBot.Ai.Communicator do
  @moduledoc """
  This module is responsible for communicating with the OpenAI API.
  """

  alias ChatBot.{Prompts, Requests}
  alias ChatBot.Prompts.Prompt

  @default_model "gpt-3.5-turbo"

  @doc """
  This function is responsible for sending a request to the OpenAI API.

  It receives a list of messages and converts it to the format that OpenAI expects.

  """
  def send(messages_list) do
    params = [
      model: model(),
      messages: [
        %{role: "system", content: prompt()} | convert_messages_to_open_ai_format(messages_list)
      ]
    ]

    {:ok, request} = create_request(params)

    params
    |> OpenAI.chat_completion()
    |> tap(&update_request(request, &1))
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

  defp model() do
    with model_name when not is_nil(model_name) <- System.get_env("AI_MODEL"),
         {:ok, model_name} <- validate_model(model_name) do
      model_name
    else
      _ -> @default_model
    end
  end

  defp validate_model(model_name) do
    {:ok, %{data: models_list}} = OpenAI.models()
    supported_model_names = Enum.map(models_list, & &1["id"])

    if model_name in supported_model_names, do: {:ok, model_name}, else: {:error, :invalid}
  end

  defp prompt() do
    with prompt_id when not is_nil(prompt_id) <- System.get_env("PROMPT_ID"),
         {prompt_id, _} <- Integer.parse(prompt_id),
         %Prompt{body: body} <- Prompts.get_prompt(prompt_id) do
      body
    else
      _ -> default_prompt()
    end
  end

  defp default_prompt() do
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

  ############################
  ###  Logging Operations  ###
  ############################

  defp create_request(params) do
    params = Enum.into(params, %{})

    Requests.create_request(%{
      url: "https://api.openai.com/v1/chat/completions",
      body: params
    })
  end

  defp update_request(request, response) do
    case response do
      {:ok, response} ->
        Requests.update_request(request, %{response: response, status_code: 200})

      {:error, %{status_code: status_code, body: body}} ->
        Requests.update_request(request, %{response: body, status_code: status_code})

      {:error, reason} ->
        Requests.update_request(request, %{response: %{error: reason}, status_code: 500})
    end
  end
end
