defmodule Proj.Threads.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :user_id, :integer
    field :topic, :string
    field :body, :string

    timestamps()
  end

  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:user_id, :topic, :body])
    |> validate_required([:user_id, :topic, :body])
    |> validate_length(:topic, min: 1)
    |> validate_length(:body, min: 1)
  end
end
