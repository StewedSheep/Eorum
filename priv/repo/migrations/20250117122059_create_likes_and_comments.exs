defmodule Proj.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    create table(:thread_likes) do
      add(:threads_id, references(:threads, on_delete: :delete_all), null: false)
      add(:users_id, references(:users, on_delete: :delete_all), null: false)
      add(:is_like, :boolean, null: false)

      timestamps(type: :utc_datetime)
    end

    create table(:comments) do
      add(:threads_id, references(:threads, on_delete: :delete_all), null: false)
      add(:users_id, references(:users, on_delete: :delete_all), null: false)
      add(:body, :text, null: false)

      timestamps(type: :utc_datetime)
    end

    create table(:comment_likes) do
      add(:comment_id, references(:comments, on_delete: :delete_all), null: false)
      add(:users_id, references(:users, on_delete: :delete_all), null: false)
      add(:is_like, :boolean, null: false)

      timestamps(type: :utc_datetime)
    end

    create(index(:thread_likes, [:threads_id]))
    create(index(:thread_likes, [:users_id]))
    create(unique_index(:thread_likes, [:threads_id, :users_id], name: :unique_thread_user_like))

    create(index(:comment_likes, [:comment_id]))
    create(index(:comment_likes, [:users_id]))

    create(
      unique_index(:comment_likes, [:comment_id, :users_id], name: :unique_comment_user_like)
    )

    create(index(:comments, [:threads_id]))
    create(index(:comments, [:users_id]))
  end
end
