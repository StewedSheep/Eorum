defmodule Proj.Threads.CommentLikes do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias Proj.Repo

  schema "comment_likes" do
    field(:is_like, :boolean, default: true)
    belongs_to(:comments, Proj.Threads.Comments)
    belongs_to(:users, Proj.Accounts.User)

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:comments_id, :users_id, :is_like])
    |> validate_required([:comments_id, :users_id, :is_like])
    |> unique_constraint(:comments_id, name: :unique_comments_user_like)
  end

  def get_comment_votes(comment_id, user_id) do
    # Query to count likes and dislikes
    query =
      from(tl in __MODULE__,
        where: tl.comments_id == ^comment_id,
        group_by: tl.is_like,
        select: {tl.is_like, count(tl.id)}
      )

    # Query to get user's current like/dislike status
    user_query =
      from(tl in __MODULE__,
        where: tl.comments_id == ^comment_id and tl.users_id == ^user_id,
        select: tl.is_like
      )

    # Execute queries
    result = Repo.all(query)
    user_reaction = Repo.one(user_query)

    # Process the results
    likes_count = Enum.into(result, %{}, fn {is_like, count} -> {is_like, count} end)

    %{
      likes: Map.get(likes_count, true, 0),
      dislikes: Map.get(likes_count, false, 0),
      user_reaction: user_reaction
    }
  end

  def add_like(attrs \\ %{}) do
    # Check for existing entry
    case Repo.get_by(__MODULE__, comments_id: attrs.comments_id, users_id: attrs.users_id) do
      nil ->
        # add a like
        %__MODULE__{}
        |> changeset(attrs)
        |> Repo.insert()

      %__MODULE__{is_like: true} = like ->
        # remove existing like
        Repo.delete(like)

      %__MODULE__{is_like: false} = like ->
        # change dislike to like
        like
        |> changeset(%{is_like: true})
        |> Repo.update()
    end
  end

  def add_dislike(attrs \\ %{}) do
    # Check for existing entry
    case Repo.get_by(__MODULE__, comments_id: attrs.comments_id, users_id: attrs.users_id) do
      nil ->
        # add a dislike
        %__MODULE__{}
        |> changeset(Map.put(attrs, :is_like, false))
        |> Repo.insert()

      %__MODULE__{is_like: false} = dislike ->
        # remove existing dislike
        Repo.delete(dislike)

      %__MODULE__{is_like: true} = like ->
        # change like to dislike
        like
        |> changeset(%{is_like: false})
        |> Repo.update()
    end
  end
end
