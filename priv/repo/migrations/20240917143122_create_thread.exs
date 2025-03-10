defmodule Proj.Repo.Migrations.CreateThread do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :users_id, references(:users)
      add :topic, :string, null: false
      add :body, :text, null: false

      timestamps()
    end

    create index(:threads, [:users_id])
  end
end
