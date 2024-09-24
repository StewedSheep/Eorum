defmodule ProjWeb.AddFriendLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  alias Proj.Accounts

  def render(assigns) do
    ~H"""
    <div class="relative flex w-96 flex-col rounded-lg border border-slate-200 bg-white shadow-sm">
      <nav class="flex min-w-[240px] flex-col gap-1 p-1.5">
        <%= for user <- @users do %>
          <%= if user.id != @current_user.id do %>
            <div
              role="button"
              class="text-slate-800 flex w-full items-center rounded-md p-3 transition-all hover:bg-slate-100 focus:bg-slate-100 active:bg-slate-100"
            >
              <div class="mr-4 grid place-items-center"></div>
              <div>
                <h6 class="text-slate-800 font-medium">
                  <%= user.username %> #<%= user.id %>
                </h6>
                <p class="text-slate-500 text-sm">
                  <%= user.email %>
                </p>
                <%= for friend <- user.received_friendships do %>
                  <%= if friend.user1 == @current_user.id and friend.user2 == user.id and friend.accepted == false do %>
                    <.button class="bg-red-700" phx-click="rem_request" phx-value-id={user.id}>
                      Remove friend request
                    </.button>
                  <% end %>
                  <%= if friend.user1 != @current_user.id and friend.user2 != @current_user.id do %>
                    <.button phx-click="add_friend" phx-value-id={user.id}>
                      Send friend request
                    </.button>
                  <% end %>
                  <%= if friend.user1 == @current_user.id and friend.user2 == user.id and friend.accepted == true do %>
                    <.button class="bg-gray-700" phx-click="rem_friend" phx-value-id={user.id}>
                      Delete friend
                    </.button>
                  <% end %>
                <% end %>
                <%= for friend <- user.sent_friendships do %>
                  <%= if friend.user2 == @current_user.id and friend.user1 == user.id do %>
                    <.button class="bg-green-700" phx-click="accept_friend" phx-value-id={user.id}>
                      Accept friend request
                    </.button>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
        <% end %>
      </nav>
    </div>
    """
  end

  @doc """
  Loads list of all users to the socket.
  """
  def mount(_params, _session, socket) do
    users = Accounts.get_users()

    IO.inspect(
      for user <- users do
        for friend <- user.received_friendships do
          IO.inspect(friend, label: "recieved_friendships")
        end

        for friend <- user.sent_friendships do
          IO.inspect(friend, label: "sent_friendships")
        end
      end
    )

    ### Create list of all the users current user has sent or received friend requests.

    socket =
      assign(socket,
        users: users
      )

    {:ok, socket}
  end

  @doc """
  Handles the "add_friend" event by creating a new friend relationship between the current user and the selected user.
  """
  def handle_event("add_friend", %{"id" => id}, socket) do
    Friends.create_friend(%{user1: socket.assigns.current_user.id, user2: id})
    {:reply, %{status: :ok, message: "Friend added successfully"}, socket}
  end

  # def handle_event("rem_request", %{"id" => id}, socket) do
  #   Friends.rem_request(%{
  #     accepted: false,
  #     personId1: socket.assigns.current_user.id,
  #     personId2: id
  #   })

  #   {:reply, %{status: :ok, message: "Removed Friend Request"}, socket}
  # end

  # def handle_event("accept_friend", %{"id" => id}, socket) do
  #   Friends.create_friend(%{personId1: socket.assigns.current_user.id, personId2: id})
  #   users = Accounts.get_users()
  #   {:ok, assign(socket, users: users)}
  # end

  # def handle_event("del_friend", %{"id" => id}, socket) do
  #   Friends.create_friend(%{personId1: socket.assigns.current_user.id, personId2: id})
  #   users = Accounts.get_users()
  #   {:ok, assign(socket, users: users)}
  # end
end
