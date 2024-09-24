defmodule Proj.Friends.Friend do
  use Ecto.Schema
  import Ecto.Changeset
  alias Proj.Accounts.User

  schema "friends" do
    field :user1, :integer
    field :user2, :integer
    belongs_to :users, User, define_field: false
    field :accepted, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friends, attrs) do
    friends
    |> cast(attrs, [:user1, :user2])
    |> validate_required([:user1, :user2])
  end
end
