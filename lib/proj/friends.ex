defmodule Proj.Friends do
  import Ecto.Query, warn: false
  alias Proj.Repo

  alias Proj.Friends.Friend

  def list_friends do
    Repo.all(from f in Friend, order_by: [desc: f.id])
  end

  def create_friend(attrs \\ %{}) do
    %Friend{}
    |> Friend.changeset(attrs)
    |> Repo.insert()
  end

  def delete_friend(%Friend{} = friend) do
    Repo.delete(friend)
  end
end
