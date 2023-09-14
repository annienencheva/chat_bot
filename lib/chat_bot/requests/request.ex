defmodule ChatBot.Requests.Request do
  use Ecto.Schema
  import Ecto.Changeset

  schema "requests" do
    field :body, :map
    field :response, :map
    field :status_code, :integer
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:url, :status_code, :body, :response])
    |> validate_required([:url, :body])
  end
end
