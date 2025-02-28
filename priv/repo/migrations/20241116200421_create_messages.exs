defmodule Proj.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:forum_general) do
      add :sender_id, :integer
      add :name, :string
      add :message, :text

      timestamps(type: :utc_datetime)
    end

    create table(:forum_technology) do
      add :sender_id, :integer
      add :name, :string
      add :message, :text

      timestamps(type: :utc_datetime)
    end

    create table(:forum_elixir) do
      add :sender_id, :integer
      add :name, :string
      add :message, :text

      timestamps(type: :utc_datetime)
    end

    create table(:forum_phoenix) do
      add :sender_id, :integer
      add :name, :string
      add :message, :text

      timestamps(type: :utc_datetime)
    end
  end
end
