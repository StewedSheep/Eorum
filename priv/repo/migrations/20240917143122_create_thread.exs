defmodule Proj.Repo.Migrations.CreateThread do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :user_id, :uuid, null: false
      add :topic, :string, null: false
      add :body, :string, null: false

      timestamps()
    end
  end
end
