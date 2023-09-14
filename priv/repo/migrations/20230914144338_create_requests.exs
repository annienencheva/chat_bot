defmodule ChatBot.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :url, :text
      add :status_code, :integer
      add :body, :map
      add :response, :map

      timestamps()
    end
  end
end
