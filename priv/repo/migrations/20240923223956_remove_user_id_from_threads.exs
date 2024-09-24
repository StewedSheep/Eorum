defmodule Proj.Repo.Migrations.RemoveUserIdFromThreads do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      remove :user_id
    end
  end
end
