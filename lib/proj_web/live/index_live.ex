defmodule ProjWeb.IndexLive do
  use ProjWeb, :live_view

  alias ProjWeb.ThreadCreateComponent
  alias Proj.Threads

  def mount(_params, _session, socket) do
    socket = assign_new(socket, :threads, fn -> Threads.list_threads() end)

    {:ok, socket}
  end

  def handle_info({:new_thread_signal, thread}, socket) do
    #Add thread to the top of the list
    {:noreply, assign(socket, :threads, [thread | socket.assigns.threads])}
  end

  def truncate_body(body) do
    body
    |> String.split("\n", trim: true)
    |> Enum.take(6)
    |> Enum.join("\n")
  end

  def render(assigns) do
    ~H"""
    <div class="space-t-4 pt-10">

      <%!-- Didnt have to make it into a live component but did just for learning sake
      (know that dead component would be preferred here as creating a new thread does not require state or live interaction)) --%>
      <.live_component module={ThreadCreateComponent} id={:new} current_user={@current_user} />

      <%!-- thread list --%>
      <%= for thread <- @threads do %>
        <div class="bg-[#F4F6D9] border-solid border-2 shadow-lg rounded-lg mx-4 md:mx-auto my-4 max-w-md md:max-w-2xl">
          <div class="flex items-start px-4 py-6">
            <div class="w-full">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-gray-900"><%= thread.topic %></h2>
                <div class="text-sm text-gray-700 flex flex-col items-end">
                  <%= Map.get(thread.users, :username, Map.get(thread, :username))   %>
                  <small class="text-sm text-gray-700">
                    <%= Calendar.strftime(thread.inserted_at, "%H:%M %d %b %y") %>
                  </small>
                </div>
              </div>
              <p class="mt-3 text-gray-700 text-sm"><%= truncate_body(thread.body) |> String.replace("\n", "<br>") |> Phoenix.HTML.raw() %></p>
              <div class="mt-4 flex items-center justify-between">
                <div class="flex flex-row gap-2">
                  <div class="flex items-center text-gray-700 text-sm">
                    <.icon name="hero-heart" class="w-6 h-6 mr-1" />
                    <span>#likes</span>
                  </div>
                  <div class="flex items-center text-gray-700 text-sm mr-4">
                    <.icon name="hero-chat-bubble-left-right" class="w-6 h-6 mr-1" />
                    <span>#comments</span>
                  </div>
                </div>
                <div class="flex items-center text-gray-700 text-sm">
                  <span class="mr-1">share</span>
                  <.icon name="hero-arrow-up-tray" class="w-6 h-6" />
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
      </div>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
