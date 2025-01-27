defmodule Proj.Threads do
  import Ecto.Query, warn: false
  alias Proj.Repo

  alias Proj.Threads.{Thread, Likes, Comments}

  def list_threads do
    Repo.all(from(t in Thread, order_by: [desc: t.id]))
    |> Repo.preload([:users, :thread_likes, :thread_comments])
  end

  def create_thread(attrs \\ %{}) do
    %Thread{}
    |> Thread.changeset(attrs)
    |> Repo.insert()
  end

  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  def change_thread(%Thread{} = thread, attrs \\ %{}) do
    Thread.changeset(thread, attrs)
  end

  def get_likes_dislikes(thread_id, user_id) do
    # Query to count likes and dislikes
    query =
      from(tl in Likes,
        where: tl.threads_id == ^thread_id,
        group_by: tl.is_like,
        select: {tl.is_like, count(tl.id)}
      )

    # Query to get user's current like/dislike status
    user_query =
      from(tl in Likes,
        where: tl.threads_id == ^thread_id and tl.users_id == ^user_id,
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
    case Repo.get_by(Likes, threads_id: attrs.threads_id, users_id: attrs.users_id) do
      nil ->
        # add a like
        %Likes{}
        |> Likes.changeset(attrs)
        |> Repo.insert()

      %Likes{is_like: true} = like ->
        # remove existing like
        Repo.delete(like)

      %Likes{is_like: false} = like ->
        # change dislike to like
        like
        |> Likes.changeset(%{is_like: true})
        |> Repo.update()
    end
  end

  def add_dislike(attrs \\ %{}) do
    # Check for existing entry
    case Repo.get_by(Likes, threads_id: attrs.threads_id, users_id: attrs.users_id) do
      nil ->
        # add a dislike
        %Likes{}
        |> Likes.changeset(Map.put(attrs, :is_like, false))
        |> Repo.insert()

      %Likes{is_like: false} = dislike ->
        # remove existing dislike
        Repo.delete(dislike)

      %Likes{is_like: true} = like ->
        # change like to dislike
        like
        |> Likes.changeset(%{is_like: false})
        |> Repo.update()
    end
  end

  def change_comment(%Comments{} = comment, attrs \\ %{}) do
    Comments.changeset(comment, attrs)
  end

  def create_comment(attrs \\ %{}) do
    %Comments{}
    |> Comments.changeset(attrs)
    |> Repo.insert()
  end
end
