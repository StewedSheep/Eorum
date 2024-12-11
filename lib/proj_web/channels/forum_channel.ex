defmodule ProjWeb.ForumChannel do
  use ProjWeb, :channel

  alias Proj.Chats

  @impl true
  def join("forum:general", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (forum:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    IO.inspect(payload, label: "shout")
    Chats.create_forum(payload)
    broadcast(socket, "shout", payload)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end