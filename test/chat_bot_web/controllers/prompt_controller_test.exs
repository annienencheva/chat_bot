defmodule ChatBotWeb.PromptControllerTest do
  use ChatBotWeb.ConnCase

  import ChatBot.PromptsFixtures

  alias ChatBot.Prompts.Prompt

  @create_attrs %{
    body: "some body"
  }
  @update_attrs %{
    body: "some updated body"
  }
  @invalid_attrs %{body: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all prompts", %{conn: conn} do
      conn = get(conn, ~p"/api/prompts")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create prompt" do
    test "renders prompt when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/prompts", prompt: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/prompts/#{id}")

      assert %{
               "id" => ^id,
               "body" => "some body"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/prompts", prompt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update prompt" do
    setup [:create_prompt]

    test "renders prompt when data is valid", %{conn: conn, prompt: %Prompt{id: id} = prompt} do
      conn = put(conn, ~p"/api/prompts/#{prompt}", prompt: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/prompts/#{id}")

      assert %{
               "id" => ^id,
               "body" => "some updated body"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, prompt: prompt} do
      conn = put(conn, ~p"/api/prompts/#{prompt}", prompt: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete prompt" do
    setup [:create_prompt]

    test "deletes chosen prompt", %{conn: conn, prompt: prompt} do
      conn = delete(conn, ~p"/api/prompts/#{prompt}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/prompts/#{prompt}")
      end
    end
  end

  defp create_prompt(_) do
    prompt = prompt_fixture()
    %{prompt: prompt}
  end
end
