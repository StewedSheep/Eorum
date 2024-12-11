defmodule Proj.Threads.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :topic, :string
    field :body, :string
    field :users_id, :integer
    belongs_to :users, Proj.Accounts.User, define_field: false

    timestamps()
  end

  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:topic, :body, :users_id])
    |> validate_required([:topic, :body, :users_id])
    |> validate_length(:topic, min: 1, max: 64)
    |> validate_length(:body, min: 1, max: 4096)
  end
end
