defmodule Proj.Repo.Migrations.CreateForum do
  use Ecto.Migration

  def change do
    create table(:forum_messages) do
      add :sender_id, :integer, null: false
      add :name, :string, null: false
      add :message, :text, null: false
      add :room, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:forum_messages, [:room])
    create index(:forum_messages, [:room, :id])
  end
end
