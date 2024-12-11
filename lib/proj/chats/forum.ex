defmodule Proj.Chats.Forum do
  use Ecto.Schema
  import Ecto.Changeset

  schema "general_messages" do
    field :sender_id, :string
    field :name, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(forum, attrs) do
    forum
    |> cast(attrs, [:sender_id, :name, :body])
    |> validate_required([:sender_id, :name, :body])
  end
end
