defmodule Proj.Threads.Likes do
  use Ecto.Schema
  import Ecto.Changeset

  schema "thread_likes" do
    field(:is_like, :boolean, default: true)
    belongs_to(:threads, Proj.Threads.Thread)
    belongs_to(:users, Proj.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:threads_id, :users_id, :is_like])
    |> validate_required([:threads_id, :users_id, :is_like])
    |> unique_constraint(:threads_id, name: :unique_threads_user_like)
  end
end
