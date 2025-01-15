defmodule Proj.Chats.Forum do
  use Ecto.Schema
  import Ecto.Changeset

  schema "general_messages" do
    field(:sender_id, :integer)
    field(:name, :string)
    field(:message, :string)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:sender_id, :name, :message])
    |> validate_required([:sender_id, :name, :message])
    |> validate_length(:message, min: 1)
  end
end
