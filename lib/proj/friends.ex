defmodule Proj.Friends do
  import Ecto.Query, warn: false
  alias Proj.Repo
  alias Proj.Friends.Friend

  def create_friend(attrs \\ %{}) do
    case Repo.get_by(Friend, attrs) do
      nil ->
        %Friend{}
        |> Friend.changeset(attrs)
        |> Repo.insert()

      existing_friend ->
        {:error, "Friend with these attributes already exists", existing_friend}
    end
  end

  def rem_request(attrs \\ %{}) do
    Repo.get_by(Friend, attrs)
    |> Repo.delete()
  end

  def delete_friend(%Friend{} = friend) do
    Repo.delete(friend)
  end

  def are_friends?(current_user_id, user_id) do
    query =
      from f in Friend,
        where:
          (f.user1 == ^current_user_id and f.user2 == ^user_id and f.accepted == true) or
            (f.user1 == ^user_id and f.user2 == ^current_user_id and f.accepted == true)

    Repo.exists?(query)
  end

  def outgoing_friend?(current_user_id, user_id) do
    Repo.exists?(
      from f in Friend,
        where: f.user1 == ^current_user_id and f.user2 == ^user_id and f.accepted == false
    )
  end

  def incoming_friend?(current_user_id, user_id) do
    Repo.exists?(
      from f in Friend,
        where: f.user1 == ^user_id and f.user2 == ^current_user_id and f.accepted == false
    )
  end
end
