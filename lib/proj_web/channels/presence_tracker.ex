defmodule ProjWeb.PresTracker do
  use ProjWeb, :channel
  alias ProjWeb.Presence

  def join("users:list", _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :user_id)}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    Presence.untrack(socket, socket.assigns.user_id)
    :ok
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end
end
