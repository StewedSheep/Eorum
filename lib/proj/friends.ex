defmodule Proj.Friends do
  import Ecto.Query, warn: false
  alias Proj.Repo
  alias Proj.Friends.Friend

  def list_friends() do
    # query =
    #   from u in User,
    #     left_join: f1 in Friend,
    #     on: f1.user1 == u.id,
    #     left_join: f2 in Friend,
    #     on: f2.user2 == u.id,
    #     group_by: u.id,
    #     select: {u.id, count(f1.id) + count(f2.id)}

    # friend_counts = Repo.all(query)

    # for {user_id, count} <- friend_counts do
    #   IO.puts("User #{user_id} has #{count} friends.")
    # end
  end

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

  # def rem_request(attrs \\ %{}) do
  #   Repo.get_by(Friend, attrs)
  #   |> Repo.delete()
  # end

  # def delete_friend(%Friend{} = friend) do
  #   Repo.delete(friend)
  # end

  # def are_friends?(current_user_id, user_id) do
  #   query =
  #     from f in Friend,
  #       where:
  #         (f.personId1 == ^current_user_id and f.personId2 == ^user_id and f.accepted == true) or
  #           (f.personId1 == ^user_id and f.personId2 == ^current_user_id and f.accepted == true)

  #   Repo.exists?(query)
  # end

  # def outgoing_friend?(current_user_id, user_id) do
  #   Repo.exists?(
  #     from f in Friend,
  #       where: f.personId1 == ^current_user_id and f.personId2 == ^user_id and f.accepted == false
  #   )
  # end

  # def incoming_friend?(current_user_id, user_id) do
  #   Repo.exists?(
  #     from f in Friend,
  #       where: f.personId1 == ^user_id and f.personId2 == ^current_user_id and f.accepted == false
  #   )
  # end
end
