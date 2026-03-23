defmodule Proj.ForumMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_rooms ["general", "elixir", "technology", "phoenix"]

  schema "forum_messages" do
    field(:name, :string)
    field(:message, :string)
    field(:room, :string)

    belongs_to(:sender, Proj.Accounts.User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message, :sender_id, :room])
    |> validate_required([:name, :message, :sender_id, :room])
    |> validate_length(:message, min: 1)
    |> validate_inclusion(:room, @valid_rooms)
  end
end
