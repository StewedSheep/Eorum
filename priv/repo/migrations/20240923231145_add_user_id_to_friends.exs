defmodule Proj.Repo.Migrations.AddUserIdToFriends do
  use Ecto.Migration

  def change do
    alter table(:friends) do
      remove :personId1
      remove :personId2
      add :user1, references(:users)
      add :user2, references(:users)
    end
  end
end
