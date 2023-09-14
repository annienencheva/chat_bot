defmodule ChatBot.PromptsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatBot.Prompts` context.
  """

  @doc """
  Generate a prompt.
  """
  def prompt_fixture(attrs \\ %{}) do
    {:ok, prompt} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> ChatBot.Prompts.create_prompt()

    prompt
  end
end
