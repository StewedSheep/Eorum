defmodule Proj.Threads.Comments do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field(:body, :string)
    field(:users_id, :integer)
    field(:threads_id, :integer)
    # belongs_to(:threads, Proj.Threads.Thread, define_field: false)
    # belongs_to(:users, Proj.Accounts.User, define_field: false)

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :users_id, :threads_id])
    |> validate_required([:body, :users_id, :threads_id])
    |> validate_length(:body, min: 1, max: 4096)
  end
end
