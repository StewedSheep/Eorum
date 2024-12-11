defmodule ProjWeb.FriendsListLive do
  use ProjWeb, :live_view

  import SaladUI.{Avatar, Card}

  alias ProjWeb.Presence
  alias Proj.Friends
  alias Proj.Accounts
  # alias Proj.Repo

  @topic "user"

  def mount(_params, %{"user_id" => user_id}, socket) do
    socket = socket |> assign_new(:current_user, fn -> Accounts.get_user!(user_id) end)
    friends = Friends.get_friends(socket.assigns.current_user.id)
    friends = Enum.map(friends, fn friend -> %{id: friend.id, username: friend.username} end)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proj.PubSub, @topic)
    end

    presences =
      Presence.simple_presence_map(Presence.list_users(@topic))

    # Match presences map with friends map
    friends =
      Enum.map(friends, fn friend ->
        status =
          if Map.has_key?(presences, Integer.to_string(friend.id)), do: :online, else: :offline

        Map.put(friend, :status, status)
      end)
      |> sort_friends_by_status()

    socket =
      socket
      |> stream(:friends, friends)
      |> assign(:presences, presences)

    {:ok, socket}
  end

  # Update presences in socket assigns according to presence_diff
  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    if socket.assigns.presences != nil do
      new_presences = Presence.handle_diff(socket.assigns.presences, diff)
      socket = assign(socket, :presences, new_presences)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # Sort friends so that :online users appear at the top
  defp sort_friends_by_status(friends) do
    Enum.sort_by(friends, fn friend ->
      case friend.status do
        :online -> 0
        :away -> 1
        :offline -> 2
      end
    end)
  end

  attr :status, :atom, values: [:online, :offline, :away], default: :offline

  def profile_icon(assigns) do
    ~H"""
    <div class="relative inline-block p-1">
      <.avatar>
        <.avatar_image src="http://example.com/badimage.png" />
        <.avatar_fallback class="w-14 h-14 bg-primary text-white">A</.avatar_fallback>
      </.avatar>
      <span class={[
        "w-4 h-4 rounded-full absolute bottom-1 right-1",
        @status == :online && "bg-green-700",
        @status == :offline && "bg-gray-300",
        @status == :away && "bg-yellow-500"
      ]}>
      </span>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div>
      <%!-- Loop through @friends --%>
      <nav class="flex min-w-[240px] flex-col gap-1 p-1.5">
      <.card
          :for={{"friends" <> _id, friend} <- @streams.friends}
          class="flex rounded-md hover:bg-slate-100 focus:bg-slate-100 rounded-lg shadow-sm"
      >
        <.profile_icon status={friend.status} />
        <.card_header class="pt-1 pl-1">
        <.card_title><%= friend.username %></.card_title>
        <.card_description>#Last message</.card_description>
        </.card_header>
      </.card>
      </nav>
    </div>
    """
  end
end
