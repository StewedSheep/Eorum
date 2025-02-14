defmodule ProjWeb.ForumChannel do
  use ProjWeb, :channel

  alias Proj.Forum
  alias ProjWeb.Presence

  @impl true
  def join("forum", payload, socket) do
    if authorized?(payload) do
      send(self(), {:after_join, payload})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # @impl true
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  @impl true
  def handle_info({:after_join, payload}, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user, %{
        online_at: inspect(System.system_time(:second)),
        room: payload["room"]
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("updated_event", payload, socket) do
    # IO.inspect(payload, label: "Received updated event payload")

    # Optionally, broadcast this update to other clients
    Presence.update_user(socket.assigns.user, "forum", payload)

    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic.
  @impl true
  def handle_in("shout", payload, socket) do
    IO.inspect(payload, label: "payload")

    Forum.create_message(payload)
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
