defmodule Proj.Repo.Migrations.AddUserIdRealtionToFriendsIndexes do
  use Ecto.Migration

  def change do
    create index(:friends, [:user1])
    create index(:friends, [:user2])
  end
end
