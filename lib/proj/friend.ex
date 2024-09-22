defmodule Proj.Friends.Friend do
  use Ecto.Schema
  import Ecto.Changeset

  schema "friends" do
    field :personId1, :integer
    field :personId2, :integer
    field :accepted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friends, attrs) do
    friends
    |> cast(attrs, [:personId1, :personId2])
    |> validate_required([:personId1, :personId2])
  end
end
