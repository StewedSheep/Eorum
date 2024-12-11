defmodule ProjWeb.AddFriendLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  alias Proj.Accounts

  def render(assigns) do
    ~H"""
    <div class="relative flex flex-col">
      <nav class="flex min-w-[240px] flex-col gap-1 p-1.5">
        <%= for user <- @users do %>
          <%= if user.id != @current_user.id do %>
            <div
              role="button"
              class="flex w-full items-center rounded-md p-3 transition-all hover:bg-slate-100 focus:bg-slate-100 rounded-lg border border-slate-200 shadow-sm"
            >
              <div class="mr-4 grid place-items-center"></div>
              <div>
                <h6 class=" font-medium p-3">
                  <%= user.username %> #<%= user.id %>
                </h6>
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
  def mount(_params, %{"user_id" => user_id}, socket) do
    socket = socket |> assign_new(:current_user, fn -> Proj.Accounts.get_user!(user_id) end)
    users = Accounts.get_users()

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

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end
end
