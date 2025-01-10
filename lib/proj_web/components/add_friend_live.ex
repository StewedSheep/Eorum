defmodule ProjWeb.AddFriendLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  alias Proj.Accounts

  def render(assigns) do
    ~H"""
    <div class="relative flex flex-col">
      <nav class="flex min-w-[240px] flex-col gap-1 p-1.5">
           <%!-- Search bar --%>
          <div class="flex flex-col w-full px-4 py-3 rounded-md border-2 border-slate-400 overflow-hidden max-w-md mx-auto font-[sans-serif]">
            <div class="flex">
             <.icon name="hero-magnifying-glass-solid" class="flex-none w-[24px] h-[24px] bg-[#6b21a8] my-2 mr-2" />
              <form class="flex-grow">
              <input type="text"
                phx-change="update_query"
                phx-debounce="200"
                name="query"
                value={@query}
                placeholder="Search For Accounts..."
                autocomplete="off"
                class="w-full bg-transparent text-sm border-none"
                />
              </form>
            </div>
            <%!-- Friend Search Results --%>
            <ul class="flex-col">
              <%= for result <- @results do %>
                <% status = friendship_status(@current_user.id, result.id) %>
                <li data-token={@token}><.user_card username={result.username} id={result.id} status={status} /></li>
              <% end %>
            </ul>
          </div>
         <%!-- List active friends and pending requests --%>
        <%= for user <- @users do %>
          <%= if user.id != @current_user.id do %>
          <% status = friendship_status(@current_user.id, user.id) %>
            <%= if status != :none do %>
              <.user_card username={user.username} id={user.id} status={status} />
            <% end %>
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
       users: users,
       query: "",
       results: [],
       token: ""
     )}
  end

  attr(:status, :atom, values: [:rec, :sent, :friends])
  attr(:username, :string, required: true)
  attr(:id, :string, required: true)

  def user_card(assigns) do
    ~H"""
      <div
            role="button"
            class="flex w-full items-center rounded-md p-3 transition-all hover:bg-slate-100 focus:bg-slate-100 rounded-lg border border-slate-200 shadow-sm"
          >
            <div class="mr-4 grid place-items-center"></div>
            <div>
              <h6 class=" font-medium p-3">
                <%= @username %> #<%= @id %>
              </h6>
                <%= case @status do %>
                  <% :none -> %>
                    <.button class="bg-violet-700" phx-click="add_friend" phx-value-id={@id}>
                      Add Friend
                    </.button>
                  <% :rec -> %>
                    <.button class="bg-green-700" phx-click="accept_friend" phx-value-id={@id}>
                      Accept request
                    </.button>
                  <% :sent -> %>
                    <.button class="bg-red-700" phx-click="rem_request" phx-value-id={@id}>
                      Remove request
                    </.button>
                  <% :friends -> %>
                    <.button class="bg-gray-700" phx-click="rem_friend" phx-value-id={@id}>
                      Delete friend
                    </.button>
                <% end %>
              </div>
            </div>
    """
  end

  def handle_event("update_query", %{"query" => query}, socket) do
    results = if query == "", do: [], else: Friends.search(query)
    IO.inspect(results, label: "results")
    IO.inspect(query, label: "query")
    {:noreply, assign(socket, query: query, results: results)}
  end

  @doc """
  Handles the "add_friend" event by creating a new friend relationship between the current user and the selected user.
  """
  def handle_event("add_friend", %{"id" => id}, socket) do
    Friends.create_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()

    {:noreply, assign(socket, users: users, token: :erlang.system_time(:millisecond))}
  end

  def handle_event("rem_friend", %{"id" => id}, socket) do
    Friends.rem_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()

    {:noreply, assign(socket, users: users, token: :erlang.system_time(:millisecond))}
  end

  def handle_event("accept_friend", %{"id" => id}, socket) do
    Friends.accept_friend(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()

    {:noreply, assign(socket, users: users, token: :erlang.system_time(:millisecond))}
  end

  def handle_event("rem_request", %{"id" => id}, socket) do
    Friends.rem_request(socket.assigns.current_user.id, String.to_integer(id))
    users = Accounts.get_users()

    {:noreply, assign(socket, users: users, token: :erlang.system_time(:millisecond))}
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
