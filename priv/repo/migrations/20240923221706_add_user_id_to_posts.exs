defmodule Proj.Repo.Migrations.AddUserIdToPosts do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      add :users_id, references(:users)
    end

    create index(:threads, [:users_id])
  end
end
