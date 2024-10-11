defmodule ProjWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  import Ecto.Query, warn: false
  alias Proj.Repo
  alias Proj.Accounts.User

  use Phoenix.Presence,
    otp_app: :proj,
    pubsub_server: Proj.PubSub

  # Populate the presence list with user schemas
  def fetch(_topic, presences) do
    query =
      from u in User,
        where: u.id in ^Map.keys(presences),
        select: {u.id, u}

    users = query |> Repo.all() |> Enum.into(%{})

    for {key, %{metas: metas}} <- presences, into: %{} do
      {key, %{metas: metas, user: users[String.to_integer(key)]}}
    end
  end
end
