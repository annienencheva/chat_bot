defmodule ChatBotWeb.Api.PromptJSON do
  alias ChatBot.Prompts.Prompt

  @doc """
  Renders a list of prompts.
  """
  def index(%{prompts: prompts}) do
    %{data: for(prompt <- prompts, do: data(prompt))}
  end

  @doc """
  Renders a single prompt.
  """
  def show(%{prompt: prompt}) do
    %{data: data(prompt)}
  end

  defp data(%Prompt{} = prompt) do
    %{
      id: prompt.id,
      body: prompt.body
    }
  end
end
