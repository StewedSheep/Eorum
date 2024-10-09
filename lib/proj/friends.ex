defmodule Proj.Friends do
  import Ecto.Query, warn: false
  alias Proj.Repo
  alias Proj.Friends.Friend

  def get_friends(current_user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^current_user_id or f.receiver_id == ^current_user_id) and
            f.accepted == true,
        preload: [:sender_user, :receiver_user]

    Repo.all(query)
  end

  def frnd_status(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^current_user_id and f.receiver_id == ^user_id) or
            (f.sender_id == ^user_id and f.receiver_id == ^current_user_id)

    Repo.one(query)
  end

  def create_friend(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^current_user_id and f.receiver_id == ^user_id) or
            (f.receiver_id == ^current_user_id and f.sender_id == ^user_id)

    case Repo.exists?(query) do
      true ->
        # Record already exists, do nothing
        nil

      false ->
        # Record doesn't exist, create a new one
        %Friend{sender_id: current_user_id, receiver_id: user_id}
        |> Repo.insert()
    end
  end

  def rem_friend(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^user_id and f.receiver_id == ^current_user_id and f.accepted == true) or
            (f.sender_id == ^current_user_id and f.receiver_id == ^user_id and f.accepted == true)

    case Repo.exists?(query) do
      true ->
        Repo.delete_all(query)

      false ->
        {:error, "Friend does not exist"}
    end
  end

  def accept_friend(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^user_id and f.receiver_id == ^current_user_id and f.accepted == false) or
            (f.sender_id == ^current_user_id and f.receiver_id == ^user_id and f.accepted == false)

    case Repo.exists?(query) do
      true ->
        Repo.update_all(query, set: [accepted: true])

      false ->
        {:error, "Friend request does not exist"}
    end
  end

  def rem_request(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.sender_id == ^user_id and f.receiver_id == ^current_user_id and f.accepted == false) or
            (f.sender_id == ^current_user_id and f.receiver_id == ^user_id and f.accepted == false)

    case Repo.exists?(query) do
      true ->
        Repo.delete_all(query)

      false ->
        {:error, "Friend request does not exist"}
    end
  end
end
