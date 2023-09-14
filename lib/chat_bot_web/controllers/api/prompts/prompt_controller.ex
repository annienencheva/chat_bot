defmodule ChatBotWeb.Api.PromptController do
  use ChatBotWeb, :controller

  alias ChatBot.Prompts
  alias ChatBot.Prompts.Prompt

  action_fallback ChatBotWeb.FallbackController

  def index(conn, _params) do
    prompts = Prompts.list_prompts()
    render(conn, :index, prompts: prompts)
  end

  def create(conn, %{"prompt" => prompt_params}) do
    with {:ok, %Prompt{} = prompt} <- Prompts.create_prompt(prompt_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/prompts/#{prompt}")
      |> render(:show, prompt: prompt)
    end
  end

  def show(conn, %{"id" => id}) do
    prompt = Prompts.get_prompt!(id)
    render(conn, :show, prompt: prompt)
  end

  def update(conn, %{"id" => id, "prompt" => prompt_params}) do
    prompt = Prompts.get_prompt!(id)

    with {:ok, %Prompt{} = prompt} <- Prompts.update_prompt(prompt, prompt_params) do
      render(conn, :show, prompt: prompt)
    end
  end

  def delete(conn, %{"id" => id}) do
    prompt = Prompts.get_prompt!(id)

    with {:ok, %Prompt{}} <- Prompts.delete_prompt(prompt) do
      send_resp(conn, :no_content, "")
    end
  end
end
