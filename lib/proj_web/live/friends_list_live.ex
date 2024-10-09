defmodule ProjWeb.FriendsListLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  # alias Proj.Accounts

  def mount(_params, _session, socket) do
    friends = Friends.get_friends(socket.assigns.current_user.id)

    for friend <- friends, do: IO.inspect(friend)

    {:ok,
     assign(socket,
       friends: friends
     )}
  end

  def render(assigns) do
    ~H"""
    <%= for friend <- @friends do %>
      <div class="relative inline-block">
        <img
          class="w-16 h-16 rounded-full border-2 border-white"
          src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
        />
        <span class="w-4 h-4 rounded-full bg-green-700 border-2 border-white absolute bottom-0.5 right-0.5">
        </span>
      </div>
      <%= if friend.sender_user.username == @current_user.username do %>
        <h1><%= friend.receiver_user.username %></h1>
      <% else %>
        <h1><%= friend.sender_user.username %></h1>
      <% end %>
      <br />
    <% end %>
    <div class="relative inline-block">
      <img
        class="w-16 h-16 rounded-full border-2 border-white"
        src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
      />
      <span class="w-4 h-4 rounded-full bg-yellow-500 border-2 border-white absolute bottom-0.5 right-0.5">
      </span>
    </div>

    <div class="relative inline-block">
      <img
        class="w-16 h-16 rounded-full border-2 border-white"
        src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
      />
      <span class="w-4 h-4 rounded-full bg-rose-700 border-2 border-white absolute bottom-0.5 right-0.5">
      </span>
    </div>

    <div class="relative inline-block">
      <img
        class="w-16 h-16 rounded-full border-2 border-white"
        src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
      />
      <span class="w-4 h-4 rounded-full bg-gray-300 border-2 border-white absolute bottom-0.5 right-0.5">
      </span>
    </div>
    """
  end
end
