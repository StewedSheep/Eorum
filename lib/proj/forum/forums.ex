defmodule Proj.Forum do
  import Ecto.Query, warn: false
  alias Proj.Repo

  alias Proj.{ForumGeneral, ForumElixir, ForumTechnology, ForumPhoenix}

  def create_message(attrs) do
    room = Map.get(attrs, "room")
    schema = schema_by_room(room)
    schema.changeset(Kernel.struct(schema), attrs) |> Proj.Repo.insert()

    # # Remove room value from attrs
    # room = Map.get(attrs, "room")
    # attrs = Map.delete(attrs, "room")
    # # Create a dynamically created changeset, by room
    # changeset = schema_by_room(room).changeset(Kernel.struct(schema_by_room(room), attrs))
    # # Insert the changeset into the database
    # Repo.insert(changeset)
    # |> case do
    #   {:ok, message} -> {:ok, message}
    #   {:error, changeset} -> {:error, changeset}
    # end
  end

  def get_messages(room \\ "general") do
    Repo.all(from(f in schema_by_room(room), order_by: [desc: f.id], limit: 20))
  end

  def get_lowest_id_on_stream(room \\ "general") do
    case Repo.one(
           from(f in schema_by_room(room),
             order_by: [desc: f.id],
             limit: 1,
             select: f.id
           )
         ) do
      nil -> 0
      id -> id
    end
  end

  def list_more_messages(last_msg_id, room) do
    Repo.all(
      from(f in schema_by_room(room),
        order_by: [desc: f.id],
        where: f.id >= ^last_msg_id - 15 and f.id <= ^last_msg_id
      )
    )
  end

  def schema_by_room(room) do
    case room do
      "general" -> ForumGeneral
      "elixir" -> ForumElixir
      "technology" -> ForumTechnology
      "phoenix" -> ForumPhoenix
    end
  end
end
