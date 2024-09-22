defmodule ProjWeb.AddFriendLive do
  use ProjWeb, :live_view

  alias Proj.Friends
  alias Proj.Accounts

  def mount(_params, _session, socket) do
    users = Accounts.get_users()

    socket =
      assign(socket,
        users: users
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="relative flex w-96 flex-col rounded-lg border border-slate-200 bg-white shadow-sm">
      <nav class="flex min-w-[240px] flex-col gap-1 p-1.5">
        <%= for user <- @users do %>
          <div
            role="button"
            class="text-slate-800 flex w-full items-center rounded-md p-3 transition-all hover:bg-slate-100 focus:bg-slate-100 active:bg-slate-100"
          >
            <div class="mr-4 grid place-items-center"></div>
            <div>
              <h6 class="text-slate-800 font-medium">
                <%= user.username %>
              </h6>
              <p class="text-slate-500 text-sm">
                <%= user.email %>
              </p>
              <.button phx-click="add_friend" phx-value-id={user.id}>Add Friend</.button>
            </div>
          </div>
        <% end %>
      </nav>
    </div>
    """
  end

  def handle_event("add_friend", %{"id" => id}, socket) do
    Friends.create_friend([socket.assigns.current_user.id, id])
    {:noreply, socket}
  end
end
