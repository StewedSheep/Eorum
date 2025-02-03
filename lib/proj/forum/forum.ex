defmodule Proj.ForumGeneral do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_general" do
    field(:name, :string)
    field(:message, :string)

    belongs_to(:sender, Proj.Accounts.User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message, :sender_id])
    |> validate_required([:name, :message, :sender_id])
    |> validate_length(:message, min: 1)
  end
end

defmodule Proj.ForumTechnology do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_technology" do
    field(:name, :string)
    field(:message, :string)

    belongs_to(:sender, Proj.Accounts.User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message, :sender_id])
    |> validate_required([:name, :message, :sender_id])
    |> validate_length(:message, min: 1)
  end
end

defmodule Proj.ForumPhoenix do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_phoenix" do
    field(:name, :string)
    field(:message, :string)

    belongs_to(:sender, Proj.Accounts.User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message, :sender_id])
    |> validate_required([:name, :message, :sender_id])
    |> validate_length(:message, min: 1)
  end
end

defmodule Proj.ForumElixir do
  use Ecto.Schema
  import Ecto.Changeset

  schema "forum_elixir" do
    field(:name, :string)
    field(:message, :string)

    belongs_to(:sender, Proj.Accounts.User)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :message, :sender_id])
    |> validate_required([:name, :message, :sender_id])
    |> validate_length(:message, min: 1)
  end
end
