defmodule ProjWeb.ForumLive do
  use ProjWeb, :live_view

  alias Proj.Chats.Forums

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proj.PubSub, "forum:general")
    end

    socket = stream(socket, :messages, Forums.get_messages())

    {:ok,
     assign(socket,
       live_action: socket.assigns.live_action,
       lowest_id: Forums.get_lowest_id() - 20
     )}
  end

  def handle_event("scrolled-to-top", _, socket) do
    if socket.assigns.lowest_id >= 1 do
      messages = Forums.list_more_messages(socket.assigns.lowest_id)
      socket = assign(socket, lowest_id: socket.assigns.lowest_id - 15)
      {:noreply, stream(socket, :messages, messages, at: 0)}
    else
      {:noreply, socket}
    end
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

  def format_timestamp(datetime) do
    # Ensure that datetime is a DateTime struct
    case DateTime.to_string(datetime) do
      str when is_binary(str) ->
        # Concatenate MM/DD and HH:MM
        "#{String.slice(str, 5..6)}/#{String.slice(str, 8..9)} #{String.slice(str, 11..15)}"

      _ ->
        "Invalid datetime"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="space-y-4 pt-10">
      <div class="flex justify-center items-stretch h-[70vh] bg-[#F4F6D9] border-solid border-purple-600 border-2 shadow-lg rounded-lg mx-4 mx-auto my-8 max-w-7xl">
        <!-- Left Sidebar -->
        <div class="w-1/6 bg-[#8054A8] text-white p-4">
          <h2 class="text-xl font-bold">Rooms</h2>
          <ul>
            <li class="pt-6">
              <div
                class="flex items-center mb-4 cursor-pointer hover:bg-purple-500 rounded-md"
                phx-click={JS.navigate("/forum/general")}
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
                phx-click={JS.navigate("/forum/technology")}
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
                phx-click={JS.navigate("/forum/elixir")}
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
                phx-click={JS.navigate("/forum/phoenix")}
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
          <div id="chat-box" phx-hook="Scroll" phx-update="stream" class="flex flex-col-reverse overflow-y-auto p-4 pb-4 flex-1 scroll-smooth">
            <%= for { _, message } <- @streams.messages do %>
              <div class={
                if message.sender_id == @current_user.id,
                  do: "flex mb-2 justify-end",
                  else: "flex mb-2 justify-start"
              }>

                <div class={
                  if message.sender_id == @current_user.id,
                    do: "flex flex-col max-w-96 rounded-lg p-3 gap-1 bg-purple-700 text-white",
                    else: "flex flex-col max-w-96 rounded-lg p-3 gap-1 bg-white text-gray-700"
                }>
                <div class="font-semibold"><%= if message.sender_id != @current_user.id, do: message.name %> </div>
                  <p><%= message.id %> <%= message.message %></p>
                  <div class={
                    if message.sender_id == @current_user.id,
                      do: "text-gray-300 text-right text-xs",
                      else: "text-gray-500 text-xs"
                  }>
                    <div class="text-sm">
                    <%= format_timestamp(message.inserted_at) %>
                  </div>
                  </div>
                </div>
              </div>
            <% end %>
          </div>
          <!-- Input Field -->
            <div class="flex items-center">
              <%!-- <input type="hidden" id="sender_id" value={@current_user.id} required /> --%>
              <input type="hidden" id="name" value={@current_user.username} required />
              <input type="hidden" id="sender-id" value={@current_user.id} required />
              <input type="text" id="msg" placeholder="Your message"
                class="flex-1 bg-white border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
                required
              />
              <button
                id="send"
                class="ml-2 bg-purple-700 text-white px-4 py-2 rounded-lg hover:bg-purple-600"
              >
                Send
              </button>
            </div>
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
    <script>
    window.userId = <%= @current_user.id %>;  // Inject the user_id into the JavaScript context
    </script>
    """
  end
end
