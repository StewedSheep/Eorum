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
                <%= case friendship_status(@current_user.id, user.id) do %>
                  <% :none -> %>
                    <.button phx-click="add_friend" phx-value-id={user.id}>
                      Send friend request
                    </.button>
                  <% :rec -> %>
                    <.button class="bg-green-700" phx-click="accept_friend" phx-value-id={user.id}>
                      Accept friend request
                    </.button>
                  <% :sent -> %>
                    <.button class="bg-red-700" phx-click="rem_request" phx-value-id={user.id}>
                      Remove friend request
                    </.button>
                  <% :friends -> %>
                    <.button class="bg-gray-700" phx-click="rem_friend" phx-value-id={user.id}>
                      Delete friend
                    </.button>
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

    for user <- users, do: IO.inspect(user)

    {:ok,
     assign(socket,
       users: users
     )}
  end

  @doc """
  Handles the "add_friend" event by creating a new friend relationship between the current user and the selected user.
  """
  def handle_event("add_friend", %{"id" => id}, socket) do
    Friends.create_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()
    {:reply, %{status: :ok, message: "Friend added successfully"}, assign(socket, users: users)}
  end

  def handle_event("rem_friend", %{"id" => id}, socket) do
    Friends.rem_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()
    {:reply, %{status: :ok, message: "Removed Friend"}, assign(socket, users: users)}
  end

  def handle_event("accept_friend", %{"id" => id}, socket) do
    Friends.accept_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()
    {:reply, %{status: :ok, message: "Friend added successfully"}, assign(socket, users: users)}
  end

  def handle_event("rem_request", %{"id" => id}, socket) do
    Friends.rem_request(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()
    {:reply, %{status: :ok, message: "Removed Friend Request"}, assign(socket, users: users)}
  end

  def friendship_status(current_user_id, user_id) do
    case Friends.frnd_status(current_user_id, user_id) do
      nil ->
        # No friendship record exists, return :none
        :none

      friend ->
        # Friendship record exists, determine the status
        cond do
          friend.accepted ->
            # Friendship is accepted, return :friends
            :friends

          friend.sender_id == current_user_id ->
            # Current user sent the friend request, return :sent
            :sent

          true ->
            # Other user sent the friend request, return :rec
            :rec
        end
    end
  end
end
