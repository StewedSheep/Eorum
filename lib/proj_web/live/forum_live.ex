defmodule ProjWeb.ForumLive do
  use ProjWeb, :live_view

  alias Proj.Forum

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proj.PubSub, "forum")
    end

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    case Map.get(params, "room") do
      room when room in ["general", "elixir", "technology", "phoenix"] ->
        # true room

        socket = stream(socket, :messages, [])
        {:noreply, switch_room(room, socket)}

      nil ->
        # blank case
        {:noreply, switch_room("general", socket)}

      _ ->
        # invalid room
        {:noreply, switch_room("general", socket)}
    end
  end

  def handle_event("new_message", %{"message" => params}, socket) do
    case Forum.create_message(params) do
      {:error, _changeset} ->
        {:noreply, socket}

      {:ok, _message} ->
        Forum.create_message(params)
        {:noreply, socket}
    end
  end

  # Add messages to the stream
  def handle_event("scrolled-to-top", _, socket) do
    if socket.assigns.lowest_id_on_stream >= 1 do
      messages =
        Forum.list_more_messages(socket.assigns.lowest_id_on_stream, socket.assigns.room)

      socket = assign(socket, lowest_id_on_stream: socket.assigns.lowest_id_on_stream - 15)
      {:noreply, stream(socket, :messages, messages, dom_id: &":messages-#{&1.id}")}
    else
      {:noreply, socket}
    end
  end

  def switch_room(room, socket) do
    socket =
      socket
      |> assign(room: room, lowest_id_on_stream: Forum.get_lowest_id_on_stream(room) - 20)
      |> stream(:messages, Forum.get_messages(room), reset: true)

    IO.inspect(room, label: "room")
    # IO.inspect(socket.assigns.streams, label: "messages")
    socket
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
                phx-click={JS.patch("/forum?room=general")}
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
                phx-click={JS.patch("/forum?room=technology")}
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
                phx-click={JS.patch("/forum?room=elixir")}
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
                phx-click={JS.patch("/forum?room=phoenix")}
              >
                <div>
                  <h2 class="text-lg font-semibold">Phoenix</h2>
                  <p class="text-gray-300">#Desc</p>
                </div>
              </div>
            </li>
          </ul>
        </div>

        <.forum_chat_room room={@room} streams={@streams} current_user={@current_user} />

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

  def forum_chat_room(assigns) do
    ~H"""

    <div id="chat" phx-hook="Chat" class="flex-1 flex flex-col">
          <header class="p-4 text-gray-700">
            <h1 class="text-2xl border-b-2 font-semibold"><%= @room %></h1>
          </header>
    <!-- Chat Messages -->
    <div id={"chat-box-#{@room}"} phx-hook="Scroll" data-room={"#{@room}"} class="flex flex-col-reverse grow overflow-y-auto">
    <table class="w-full">

      <tbody id="messages" phx-update="stream" class="flex flex-col-reverse scroll-smooth">

        <tr
          :for={{dom_id, message} <- @streams.messages}
          id={dom_id}
          class={"flex mb-2 px-2 " <>
            if message.sender_id == @current_user.id,
              do: "justify-end",
              else: "justify-start"
          }
        >
          <td class={"flex flex-col max-w-96 rounded-lg p-3 gap-1 " <>
              if message.sender_id == @current_user.id,
                do: "bg-purple-700 text-white",
                else: "bg-white text-gray-700"
            }>
            <div class="font-semibold">
              <%= if message.sender_id != @current_user.id, do: message.name %>
            </div>
            <p><%= message.message %></p>
            <div class={
                if message.sender_id == @current_user.id,
                  do: "text-gray-300 text-right text-xs",
                  else: "text-gray-500 text-xs"
              }>
              <div class="text-sm">
                <%= Calendar.strftime(message.inserted_at, "%H:%M %d %b") %>
              </div>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
    </div>
          <!-- Input Field -->
            <div class="flex relative bottom-0 items-center">
              <input hidden id="name" value={@current_user.username} required />
              <input hidden id="sender-id" value={@current_user.id} required />
              <input hidden id="room" value={@room} required />
              <input type="text" id="msg" placeholder="Your message"
                class="flex-1 bg-white border border-gray-300 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500"
                required
              />
              <button
                id="send"
                phx-submit="new_message"
                class="ml-2 bg-purple-700 text-white px-4 py-2 rounded-lg hover:bg-purple-600"
              >
                Send
              </button>
              </div>
            <script>
            // Inject the user_id into the JavaScript context to check if the message belongs to the current user
            window.userId = <%= @current_user.id %>;
            </script>
            </div>

    """
  end
end
