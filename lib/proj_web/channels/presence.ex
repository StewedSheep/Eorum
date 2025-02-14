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
    user_metas = get_by_key(topic, user.id)

    if user_metas != [] do
      %{metas: [meta]} = user_metas

      update(self(), topic, user.id, Map.merge(meta, new_meta))
    end
  end

  def handle_diff(presences, diff) do
    # IO.inspect(presences, label: "presences")
    # IO.inspect(diff, label: "diff")

    presences
    |> remove_presences(diff.leaves)
    |> add_presences(diff.joins)
  end

  def add_presences(presences, joins) do
    Map.merge(presences, simple_presence_map(joins))
  end

  defp remove_presences(presences, leaves) do
    user_ids =
      Enum.map(leaves, fn {user_id, _} ->
        user_id
      end)

    Map.drop(presences, user_ids)
  end

  # Populate the presence list with user schemas
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
