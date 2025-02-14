defmodule Proj.Threads.Comments do
  use Ecto.Schema
  import Ecto.Changeset

  alias Proj.Repo

  schema "comments" do
    field(:body, :string)
    # field(:users_id, :integer)
    # field(:threads_id, :integer)
    belongs_to(:threads, Proj.Threads.Thread)
    belongs_to(:users, Proj.Accounts.User)
    has_many(:comment_likes, Proj.Threads.CommentLikes, foreign_key: :comments_id)

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :users_id, :threads_id])
    |> validate_required([:body, :users_id, :threads_id])
    |> validate_length(:body, min: 1, max: 4096)
  end

  def change_comment(%__MODULE__{} = comment, attrs \\ %{}) do
    changeset(comment, attrs)
  end

  def delete_comment_by_id(id) do
    comment = Repo.get!(__MODULE__, String.to_integer(id))
    Repo.delete(comment)
  end

  def create_comment(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end
end
