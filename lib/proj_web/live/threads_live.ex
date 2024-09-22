defmodule ProjWeb.ThreadsLive do
  use ProjWeb, :live_view

  alias ProjWeb.PostFormComponent
  alias Proj.Threads
  alias Proj.Accounts

  def mount(_params, _session, socket) do
    threads = Threads.list_threads()

    socket =
      assign(socket,
        threads: threads
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%!-- Didnt have to make it into a live component but did just for learning sake --%>
    <.live_component module={PostFormComponent} id={:new} current_user={@current_user} />

    <%!-- thread list --%>
    <div class="space-y-4">
      <%= for thread <- @threads do %>
        <div class="bg-white shadow-lg rounded-lg mx-4 md:mx-auto my-8 max-w-md md:max-w-2xl">
          <div class="flex items-start px-4 py-6">
            <div class="w-full">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-semibold text-gray-900"><%= thread.topic %></h2>
                <div class="text-sm text-gray-700 flex flex-col items-end">
                  <%= Accounts.get_user!(thread.user_id).username %>
                  <small class="text-sm text-gray-700">
                    <%= Calendar.strftime(thread.inserted_at, "%H:%M %d %b %y") %>
                  </small>
                </div>
              </div>
              <p class="mt-3 text-gray-700 text-sm"><%= thread.body %></p>
              <div class="mt-4 flex items-center justify-between">
                <div class="flex flex-row gap-2">
                  <div class="flex items-center text-gray-700 text-sm">
                    <svg fill="none" viewBox="0 0 24 24" class="w-4 h-4 mr-1" stroke="currentColor">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z"
                      />
                    </svg>
                    <span>#likes</span>
                  </div>
                  <div class="flex items-center text-gray-700 text-sm mr-4">
                    <svg fill="none" viewBox="0 0 24 24" class="w-4 h-4 mr-1" stroke="currentColor">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"
                      />
                    </svg>
                    <span>#comments</span>
                  </div>
                </div>
                <div class="flex items-center text-gray-700 text-sm">
                  <svg fill="none" viewBox="0 0 24 24" class="w-4 h-4 mr-1" stroke="currentColor">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"
                    />
                  </svg>
                  <span>share</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
