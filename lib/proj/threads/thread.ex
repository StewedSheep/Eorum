defmodule Proj.Threads.Thread do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Proj.Repo
  alias Proj.Threads.{ThreadLikes, Comments}

  schema "threads" do
    field(:topic, :string)
    field(:body, :string)
    belongs_to(:users, Proj.Accounts.User)

    has_many(:thread_likes, ThreadLikes, foreign_key: :threads_id)
    has_many(:thread_comments, Comments, foreign_key: :threads_id)
    timestamps()
  end

  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:topic, :body, :users_id])
    |> validate_required([:topic, :body, :users_id])
    |> validate_length(:topic, min: 1, max: 64)
    |> validate_length(:body, min: 1, max: 4096)
    |> foreign_key_constraint(:users_id)
  end

  def list_threads(page, per_page, sort_by) do
    offset = (page - 1) * per_page

    query =
      from(t in __MODULE__,
        left_join: comments in assoc(t, :thread_comments),
        left_join: likes in assoc(t, :thread_likes),
        group_by: t.id
      )

    query =
      case sort_by do
        "newest" ->
          from([t] in query,
            order_by: [desc: t.id]
          )

        "popular" ->
          from([t, comments, likes] in query,
            order_by: [
              desc: fragment("COUNT(?) + COUNT(?)", comments.id, likes.id)
            ]
          )

        _ ->
          from([t] in query,
            # default to newest
            order_by: [desc: t.id]
          )
      end

    Repo.all(
      from(t in query,
        limit: ^per_page,
        offset: ^offset
      )
    )
    |> Repo.preload([:thread_likes, :thread_comments, :users])
  end

  def total_pages(per_page) do
    total =
      Repo.one(
        from(t in __MODULE__,
          select: count(t.id)
        )
      )

    if Integer.mod(total, per_page) == 0 do
      div(total, per_page)
    else
      div(total, per_page) + 1
    end
  end

  def create_thread(attrs \\ %{}) do
    %__MODULE__{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def delete_thread(%__MODULE__{} = thread) do
    Repo.delete(thread)
  end

  def delete_thread_by_id(id) do
    thread = Repo.get!(__MODULE__, String.to_integer(id))
    Repo.delete(thread)
  end

  def change_thread(%__MODULE__{} = thread, attrs \\ %{}) do
    changeset(thread, attrs)
  end
end
