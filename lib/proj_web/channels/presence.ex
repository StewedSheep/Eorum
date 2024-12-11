defmodule ProjWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  import Ecto.Query, warn: false
  # alias Proj.Repo
  # alias Proj.Accounts.User

  use Phoenix.Presence,
    otp_app: :proj,
    pubsub_server: Proj.PubSub

  def simple_presence_map(presences) do
    Enum.into(presences, %{}, fn {user_id, %{metas: [meta | _]}} ->
      {user_id, meta}
    end)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(Proj.PubSub, topic)
  end

  def list_users(topic) do
    list(topic)
  end

  def update_user(user, topic, new_meta) do
    %{metas: [meta | _]} = get_by_key(topic, user.id)

    update(self(), topic, user.id, Map.merge(meta, new_meta))
  end

  def handle_diff(socket, diff) do
    socket
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  def add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, simple_presence_map(joins))

    Phoenix.Component.assign(socket, presences: presences)
  end

  defp remove_presences(socket, leaves) do
    user_ids =
      Enum.map(leaves, fn {user_id, _} -> user_id end)

    presences = Map.drop(socket.assigns.presences, user_ids)

    Phoenix.Component.assign(socket, presences: presences)
  end

  # Populate the presence list with user schemas
  # TODO : Delete this if not used
  # def fetch(_topic, presences) do
  #   IO.inspect(presences)

  #   query =
  #     from u in User,
  #       where: u.id in ^Map.keys(presences),
  #       select: {u.id, u}

  #   users = query |> Repo.all() |> Enum.into(%{})

  #   for {key, %{metas: metas}} <- presences, into: %{} do
  #     {key, %{metas: metas, user: users[String.to_integer(key)]}}
  #   end
  # end
end
