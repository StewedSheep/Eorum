defmodule Proj.Repo.Migrations.CreateFriends do
  use Ecto.Migration

  def change do
    create table(:friends) do
      add :sender_id, :integer
      add :receiver_id, :integer
      add :accepted, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:friends, [:sender_id])
    create index(:friends, [:receiver_id])
  end
end
