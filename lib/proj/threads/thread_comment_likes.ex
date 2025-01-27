defmodule Proj.Threads.CommentLikes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comment_likes" do
    field(:is_like, :boolean, default: true)
    belongs_to(:threads, Proj.Threads.Thread)
    belongs_to(:user, Proj.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:threads_id, :user_id, :is_like])
    |> validate_required([:threads_id, :user_id, :is_like])
    |> unique_constraint(:threads_id, name: :unique_threads_user_like)
  end
end
