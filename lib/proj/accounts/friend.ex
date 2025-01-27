defmodule Proj.Friends.Friend do
  use Ecto.Schema
  import Ecto.Changeset
  alias Proj.Accounts.User

  schema "friends" do
    field(:accepted, :boolean, default: false)
    belongs_to(:sender_user, User, foreign_key: :sender_id)
    belongs_to(:receiver_user, User, foreign_key: :receiver_id)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(friends, attrs) do
    friends
    |> cast(attrs, [:sender_id, :receiver_id])
    |> validate_required([:sender_id, :receiver_id])
  end
end
