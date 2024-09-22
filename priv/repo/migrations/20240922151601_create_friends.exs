defmodule Proj.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :personId1, :integer
      add :personId2, :integer
      add :accepted, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
