defmodule ChatBot.RequestsTest do
  use ChatBot.DataCase

  alias ChatBot.Requests

  describe "requests" do
    alias ChatBot.Requests.Request

    import ChatBot.RequestsFixtures

    @invalid_attrs %{body: nil, response: nil, status_code: nil, url: nil}

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Requests.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Requests.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{body: %{}, response: %{}, status_code: 42, url: "some url"}

      assert {:ok, %Request{} = request} = Requests.create_request(valid_attrs)
      assert request.body == %{}
      assert request.response == %{}
      assert request.status_code == 42
      assert request.url == "some url"
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Requests.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      update_attrs = %{body: %{}, response: %{}, status_code: 43, url: "some updated url"}

      assert {:ok, %Request{} = request} = Requests.update_request(request, update_attrs)
      assert request.body == %{}
      assert request.response == %{}
      assert request.status_code == 43
      assert request.url == "some updated url"
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Requests.update_request(request, @invalid_attrs)
      assert request == Requests.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Requests.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Requests.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Requests.change_request(request)
    end
  end
end
