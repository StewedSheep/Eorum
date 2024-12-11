defmodule Proj.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:general_messages) do
      add :sender_id, :integer
      add :name, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end

    create table(:technology_messages) do
      add :sender_id, :integer
      add :name, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end

    create table(:elixir_messages) do
      add :sender_id, :integer
      add :name, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end

    create table(:plv_messages) do
      add :sender_id, :integer
      add :name, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
