defmodule Proj.Forum do
  import Ecto.Query, warn: false
  alias Proj.Repo
  alias Proj.ForumMessage

  def create_message(attrs) do
    %ForumMessage{}
    |> ForumMessage.changeset(attrs)
    |> Repo.insert()
  end

  def get_messages(room \\ "general") do
    Repo.all(
      from f in ForumMessage,
        where: f.room == ^room,
        order_by: [desc: f.id],
        limit: 20
    )
  end

  def list_more_messages(before_id, room) do
    Repo.all(
      from f in ForumMessage,
        where: f.room == ^room and f.id < ^before_id,
        order_by: [desc: f.id],
        limit: 15
    )
  end
end
