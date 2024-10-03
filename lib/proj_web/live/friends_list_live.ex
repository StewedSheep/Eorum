defmodule ProjWeb.FriendsListLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  # alias Proj.Accounts

  def mount(_params, _session, socket) do
    friends = Friends.get_friends(socket.assigns.current_user.id)

    {:ok,
     assign(socket,
       friends: friends
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex flex-col">
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
        <span class="w-4 h-4 rounded-full bg-green-700 border-2 border-white absolute bottom-0.5 right-0.5">
        </span>
      </div>
      <div class="relative inline-block">
        <img
          class="w-16 h-16 rounded-full border-2 border-white"
          src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
        />
        <span class="w-4 h-4 rounded-full bg-green-700 border-2 border-white absolute bottom-0.5 right-0.5">
        </span>
      </div>
      <div class="relative inline-block">
        <img
          class="w-16 h-16 rounded-full border-2 border-white"
          src="https://www.feedingmatters.org/wp-content/uploads/2020/02/placeholder-user-400x400-1.png"
        />
        <span class="w-4 h-4 rounded-full bg-green-700 border-2 border-white absolute bottom-0.5 right-0.5">
        </span>
      </div>
    </div>
    """
  end
end
