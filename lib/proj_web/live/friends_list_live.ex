defmodule ProjWeb.FriendsListLive do
  use ProjWeb, :live_view

  alias ProjWeb.Presence
  alias Proj.Friends
  # alias Proj.Accounts.User
  # alias Proj.Repo

  @topic "users:list"

  def mount(_params, _session, socket) do
    friends = Friends.get_friends(socket.assigns.current_user.id)

    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proj.PubSub, @topic)

      {:ok, _} =
        Presence.track(self(), @topic, current_user.id, %{
          is_away: false
        })
    end

    presences = Presence.list(@topic)

    {:ok,
     assign(socket,
       presences: presences,
       friends: friends
     )}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket =
      socket
      |> remove_presences(diff.leaves)
      |> add_presences(diff.joins)

    {:noreply, socket}
  end

  defp remove_presences(socket, leaves) do
    user_ids = Enum.map(leaves, fn {user_id, _} -> user_id end)
    presences = Map.drop(socket.assigns.presences, user_ids)
    assign(socket, presences: presences)
  end

  defp add_presences(socket, joins) do
    presences = Map.merge(socket.assigns.presences, joins)
    assign(socket, presences: presences)
  end

  def render(assigns) do
    ~H"""
    <%!-- :for={{user_id, %{metas: [meta | _], user: user}} <- @presences} } --%>
    <%!-- Loop through @friends --%>
    <ul :for={user <- @friends}>
      <div class="relative inline-block">
        <img
          class="w-16 h-16 rounded-full border-2 border-white"
          src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
        />
        <%= case Map.has_key?(@presences, to_string(user.id)) do %>
          <% true -> %>
            <span class="w-4 h-4 rounded-full bg-green-700 border-2 border-white absolute bottom-0.5 right-0.5">
            </span>
          <% false -> %>
            <span class="w-4 h-4 rounded-full bg-gray-300 border-2 border-white absolute bottom-0.5 right-0.5">
            </span>
        <% end %>
      </div>
      <p class="text-white"><%= user.id %> - <%= user.username %></p>
      <br />
    </ul>

    <span class="bg-yellow-500"></span>
    <span class=""></span>

    <%!-- <%= for presence <- @presences do %> --%>
    <pre class="text-white">
      <%= inspect(@current_user.id, pretty: true) %>
    </pre>
    <%!-- <% end %> --%>
    """
  end
end
