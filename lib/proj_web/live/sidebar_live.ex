defmodule ProjWeb.SidebarLive do
  use ProjWeb, :live_view

  def mount(_params, session, socket) do
    socket =
      assign(socket,
        selected_tab: :tab_1,
        sidebar_open: false,
        current_user: Map.get(session, "current_user")
      )

    {:ok, socket, layout: false}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    selected_tab = String.to_existing_atom(tab)
    {:noreply, assign(socket, selected_tab: selected_tab)}
  end

  def handle_event("toggle_sidebar", _params, socket) do
    sidebar_open = !socket.assigns.sidebar_open

    {:noreply,
     socket
     |> assign(:sidebar_open, sidebar_open)
     |> push_event("sidebar_toggle", %{sidebar_open: sidebar_open})}
  end

  def render(assigns) do
    ~H"""
    <%!-- "absolute z-20 bg-[#FFFE73] right-0 w-[400px] h-[calc(100vh-114px)] max-h-[calc(100vh-114px)] overflow-y-auto transition-all hidden" --%>
    <div class={[
      "fixed h-[calc(100vh-104px)] max-h-[calc(100vh-104px)] right-0 z-20 h-full w-[400px] bg-[#F4F6D9] shadow-lg overflow-y-auto transition-all",
      @sidebar_open && "translate-x-0",
      !@sidebar_open && "translate-x-full"
    ]}>
      <div class="inline-flex flex-row">
        <!-- Sidebar -->
        <div class="p-4">
          <!-- Tabs -->
          <div class="flex flex-row w-full justify-between space-x-2">
            <button
              phx-click="switch_tab"
              phx-value-tab="tab_1"
              class="grow py-2 px-4 font-semibold text-[#416F3F] hover:text-[#5C9E58]"
            >
              Friends
            </button>
            <button
              phx-click="switch_tab"
              phx-value-tab="tab_2"
              class="grow py-2 px-4 font-semibold text-[#416F3F] hover:text-[#5C9E58]"
            >
              Find Users
            </button>
          </div>
          <!-- Dynamic Content -->
          <div class="mt-4 w-[370px]">
            <%= case @selected_tab do %>
              <% :tab_1 -> %>
                <%!-- Component for rendering the friends list tab content --%>
                <%= if connected?(@socket) && @selected_tab == :tab_1 do %>
                  {live_render(@socket, ProjWeb.FriendsListLive,
                    id: "friends_component",
                    session: %{"user_id" => @current_user.id}
                  )}
                <% end %>
              <% :tab_2 -> %>
                <%!-- Component for rendering the add users tab content --%>
                <%= if connected?(@socket) && @selected_tab == :tab_2 do %>
                  <div class="">
                    {live_render(@socket, ProjWeb.AddFriendLive,
                      id: "add_users_component",
                      session: %{"user_id" => @current_user.id}
                    )}
                  </div>
                <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
