defmodule Proj.Chats.Forums do
  import Ecto.Query, warn: false
  alias Proj.Repo

  alias Proj.Chats.Forum

  def create_message(attrs) do
    %Proj.Chats.Forum{}
    |> Forum.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} -> {:ok, message}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def get_messages() do
    Repo.all(from(f in Forum, order_by: [desc: f.id], limit: 20))
  end

  def get_lowest_id() do
    Repo.one(
      from(f in Forum,
        order_by: [desc: f.id],
        limit: 1,
        select: f.id
      )
    )
  end

  def list_more_messages(last_msg_id) do
    Repo.all(
      from(f in Forum,
        order_by: [desc: f.id],
        where: f.id >= ^last_msg_id - 15 and f.id <= ^last_msg_id
      )
    )
  end
end
