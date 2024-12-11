defmodule ProjWeb.ChatLive do
  use ProjWeb, :live_view

  # alias Proj.Chats

  def mount(_params, _session, socket) do
    messages = [
      %{id: 1, sender_id: 1, name: "Alice", message: "Hi there!", timestamp: "10:00 AM"}
    ]

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proj.PubSub, "forum:general")
    end

    {:ok, assign(socket, live_action: socket.assigns.live_action, messages: messages)}
  end

  def handle_info({:message, room_name, message}, socket) do
    current_room = socket.assigns.live_action

    if current_room && room_name == String.to_integer(room_name) do
      send_update(ProjWeb.ChatLive,
        id: "chat-#{current_room}",
        messages: [message | socket.assigns.messages]
      )
    end
  end

  def handle_event("add_artificial_message", _params, socket) do
    # Define artificial data
    new_message = %{
      id: Enum.count(socket.assigns.messages) + 1,
      sender_id: 99,
      name: "Artificial User",
      message: "This is an artificial message.",
      timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.to_string()
    }

    # Update the list of messages
    updated_messages = [new_message | socket.assigns.messages]

    {:noreply, assign(socket, :messages, updated_messages)}
  end

  # Handle routing logic
  def handle_params(%{"category" => category}, _uri, socket)
      when socket.assigns.live_action in [:category] do
    case category do
      c when c in ["technology", "elixir", "phoenix"] ->
        {:noreply, assign(socket, category: String.capitalize(category))}

      _ ->
        {:noreply, assign(socket, category: "General")}
    end
  end

  # Routes "without a category" to general
  def handle_params(_params, _uri, socket) when socket.assigns.live_action == :index do
    {:noreply, assign(socket, category: "General")}
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 pt-10">
      <button phx-click="add_artificial_message" class="bg-blue-500 text-white px-4 py-2 rounded">
        Add Artificial Message
      </button>
      <div class="flex justify-center items-stretch h-[70vh] bg-[#F4F6D9] border-solid border-purple-600 border-2 shadow-lg rounded-lg mx-4 mx-auto my-8 max-w-7xl">
        <!-- Left Sidebar -->
        <div class="w-1/6 bg-[#8054A8] text-white p-4">
          <h2 class="text-xl font-bold">Rooms</h2>
          <ul>
            <li class="pt-6">
              <div
                class="flex items-center mb-4 cursor-pointer hover:bg-purple-500 rounded-md"
                phx-click={JS.navigate("/chat/general")}
              >
                <div>
                  <h2 class="text-lg font-semibold">General</h2>
                  <p class="text-gray-300">#Desc</p>
                </div>
              </div>
            </li>
            <li>
              <div
                class="flex items-center mb-4 cursor-pointer hover:bg-purple-500 rounded-md"
                phx-click={JS.navigate("/chat/technology")}
              >
                <div>
                  <h2 class="text-lg font-semibold">Technology</h2>
                  <p class="text-gray-300">#Desc</p>
                </div>
              </div>
            </li>
            <li>
              <div
                class="flex items-center mb-4 cursor-pointer hover:bg-purple-500 rounded-md"
                phx-click={JS.navigate("/chat/elixir")}
              >
                <div>
                  <h2 class="text-lg font-semibold">Elixir</h2>
                  <p class="text-gray-300">#Desc</p>
                </div>
              </div>
            </li>
            <li>
              <div
                class="flex items-center mb-4 cursor-pointer hover:bg-purple-500 rounded-md"
                phx-click={JS.navigate("/chat/phoenix")}
              >
                <div>
                  <h2 class="text-lg font-semibold">Phoenix</h2>
                  <p class="text-gray-300">#Desc</p>
                </div>
              </div>
            </li>
          </ul>
        </div>
        <!-- Main Content -->
        <div class="flex-1 flex flex-col">
          <header class="p-4 text-gray-700">
            <h1 class="text-2xl border-b-2 font-semibold"><%= @category %></h1>
          </header>
          <!-- Chat Messages -->
          <div id="chat-box" class="overflow-y-auto p-4 pb-4 flex-1">
            <!-- Incoming Message -->
            <div class="flex mb-4">
              <div class="flex flex-col">
                <div class="flex justify-between text-sm pt-2">
                  <span class="font-medium text-gray-600">Alice</span>
                  <span class="text-gray-500">Nov 24, 2024</span>
                </div>
                <div class="flex max-w-96 bg-white rounded-lg p-3 gap-3">
                  <p class="text-gray-700">Hey Bob, how's it going?</p>
                </div>
              </div>
            </div>
            <!-- Outgoing Message -->
            <div class="flex justify-end mb-4">
              <div class="flex flex-col">
                <!-- User and date information -->
                <div class="flex justify-between text-sm pt-2">
                  <span class="font-medium text-gray-600">Bob</span>
                  <span class="text-gray-500">Nov 24, 2024</span>
                </div>
                <div class="flex max-w-96 bg-purple-700 text-white rounded-lg p-3 gap-3">
                  <!-- Message content -->
                  <p>
                    Hi Alice! I'm good, just finished a great book. How about you?
                  </p>
                </div>
              </div>
            </div>
            <%= for message <- @messages do %>
              <div class={
                if message.sender_id == @current_user.id,
                  do: "flex mb-4 justify-end",
                  else: "flex mb-4 justify-start"
              }>
                <div class={
                  if message.sender_id == @current_user.id,
                    do: "flex flex-col max-w-96 rounded-lg p-3 gap-2 bg-purple-700 text-white",
                    else: "flex flex-col max-w-96 rounded-lg p-3 gap-2 bg-white text-gray-700"
                }>
                  <p><%= message.message %></p>
                  <div class={
                    if message.sender_id == @current_user.id,
                      do: "text-gray-300 text-right text-xs",
                      else: "text-gray-500 text-xs"
                  }>
                    <%= if message.sender_id == @current_user.id, do: "You", else: message.name %> - <%= message.timestamp %>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
          <!-- Input Field -->
          <form id="chat-form" class="bg-gray-100 p-4 border-t border-gray-300">
            <div class="flex items-center">
              <input type="hidden" id="user-id" value={@current_user.id} required />
              <input type="hidden" id="user-name" value={@current_user.username} required />
              <input
                type="text"
                id="user-msg"
                placeholder="Type a message..."
                class="flex-1 bg-white border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
                required
              />
              <button
                type="submit"
                class="ml-2 bg-purple-700 text-white px-4 py-2 rounded-lg hover:bg-purple-600"
              >
                Send
              </button>
            </div>
          </form>
        </div>
        <!-- Active Users Sidebar -->
        <div class="w-1/6 bg-[#8054A8] text-white p-4">
          <h2 class="text-xl font-bold">Active Users</h2>
          <ul class="pt-6">
            <li class="p-1">User 1</li>
            <li class="p-1">User 2</li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
