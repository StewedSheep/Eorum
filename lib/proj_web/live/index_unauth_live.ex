defmodule ProjWeb.IndexUnAuthLive do
  use ProjWeb, :live_view

  alias ProjWeb.IndexLive.ThreadLive
  alias Proj.Threads.{Thread, ThreadLikes}

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       per_page: 10,
       sort_by: "newest",
       current_page: 1,
       total_pages: Thread.total_pages(10),
       threads: Thread.list_threads(1, 10, "newest")
     )}
  end

  def handle_event("change_page", %{"page" => page}, socket) do
    page = String.to_integer(page)

    if page > 0 and page <= socket.assigns.total_pages do
      {:noreply,
       assign(socket,
         current_page: page,
         total_pages: Thread.total_pages(socket.assigns.per_page),
         threads: Thread.list_threads(page, socket.assigns.per_page, socket.assigns.sort_by)
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select_sort_by", %{"sort_by" => sort_by}, socket) do
    {:noreply,
     assign(socket,
       sort_by: sort_by,
       threads: Thread.list_threads(socket.assigns.current_page, socket.assigns.per_page, sort_by)
     )}
  end

  def handle_event("select_per_page", %{"per_page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    {:noreply,
     assign(socket,
       per_page: per_page,
       total_pages: Thread.total_pages(per_page),
       current_page: 1,
       threads:
         Thread.list_threads(
           socket.assigns.current_page,
           per_page,
           socket.assigns.sort_by
         )
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="space-t-4 pt-10">
      <.pagination_shelf
        current_page={@current_page}
        total_pages={@total_pages}
        per_page={@per_page}
        sort_by={@sort_by}
      />
      <%!-- thread list --%>
      <%= for thread <- @threads do %>
        <%!-- <%= inspect(thread) %> --%>
        <.live_component
          module={ThreadLive}
          id={thread.id}
          current_user={%Proj.Accounts.User{id: 0}}
          thread={thread}
          show_full={false}
          comment_toggle="0"
          show_thread_delete_modal={false}
          thread_votes={ThreadLikes.get_thread_votes(thread.id)}
        />
      <% end %>
      <.pagination_shelf
        current_page={@current_page}
        total_pages={@total_pages}
        per_page={@per_page}
        sort_by={@sort_by}
      />
    </div>
    """
  end

  def pagination_shelf(assigns) do
    ~H"""
    <div class="flex items-center justify-center md:mx-auto max-w-md md:max-w-2xl">
      <%!-- <%= inspect @total_pages %> --%>
      <div class="w-full mt-1 px-8 bg-purple-700 p-1 rounded-lg shadow-sm">
        <div class="flex justify-between">
          <!-- Items per page dropdown -->
          <div>
            <h1 class="flex items-center justify-center font-bold text-white">Per page</h1>
            <div class="grid grid-cols-4 gap-2">
              <button phx-click="select_per_page" phx-value-per_page={10}>
                <label
                  for="10"
                  class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @per_page == 10, do: "bg-purple-500 font-bold", else: ""}"}
                >
                  10
                </label>
              </button>

              <button phx-click="select_per_page" phx-value-per_page={15}>
                <label
                  for="15"
                  class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @per_page == 15, do: "bg-purple-500 font-bold", else: ""}"}
                >
                  15
                </label>
              </button>

              <button phx-click="select_per_page" phx-value-per_page={20}>
                <label
                  for="20"
                  class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @per_page == 20, do: "bg-purple-500 font-bold", else: ""}"}
                >
                  20
                </label>
              </button>

              <button phx-click="select_per_page" phx-value-per_page={25}>
                <label
                  for="25"
                  class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @per_page == 25, do: "bg-purple-500 font-bold", else: ""}"}
                >
                  25
                </label>
              </button>
            </div>
          </div>

          <nav class="flex space-x-2">
            <a
              phx-click="change_page"
              phx-value-page={1}
              class="relative inline-flex items-center px-4 py-2 text-sm bg-[#9741E8] border border-purple-600 hover:bg-violet-400 text-white font-semibold cursor-pointer leading-5 rounded-md"
            >
              <.icon name="hero-chevron-double-left" class="w-4 h-4" />
            </a>
            <a
              phx-click="change_page"
              phx-value-page={@current_page - 1}
              class="relative inline-flex items-center px-4 py-2 text-sm bg-[#9741E8] border border-purple-600 hover:bg-violet-400 text-white font-semibold cursor-pointer leading-5 rounded-md"
            >
              <.icon name="hero-chevron-left" class="w-4 h-4" />
            </a>
            <a
              phx-click="change_page"
              class="relative inline-flex items-center px-4 py-2 text-sm bg-white font-medium text-gray-700 border border-purple-600 cursor-pointer leading-5 rounded-md"
            >
              {@current_page}
            </a>
            <a
              phx-click="change_page"
              phx-value-page={@current_page + 1}
              class="relative inline-flex items-center px-4 py-2 text-sm bg-[#9741E8] border border-purple-600 hover:bg-violet-400 text-white font-semibold cursor-pointer leading-5 rounded-md"
            >
              <.icon name="hero-chevron-right" class="w-4 h-4" />
            </a>
            <a
              phx-click="change_page"
              phx-value-page={@total_pages}
              class="relative inline-flex items-center px-4 py-2 text-sm bg-[#9741E8] border border-purple-600 hover:bg-violet-400 text-white font-semibold cursor-pointer leading-5 rounded-md"
            >
              <.icon name="hero-chevron-double-right" class="w-4 h-4" />
            </a>
          </nav>

    <!-- Sort order dropdown -->
          <div class="flex justify-between">
            <!-- Items per page dropdown -->
            <div>
              <h1 class="flex items-center justify-center font-bold text-white">Sort by</h1>
              <div class="grid grid-cols-2 gap-2">
                <button phx-click="select_sort_by" phx-value-sort_by="newest">
                  <label
                    for="newest"
                    class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @sort_by == "newest", do: "bg-purple-500 font-bold", else: ""}"}
                  >
                    Newest
                  </label>
                </button>

                <button phx-click="select_sort_by" phx-value-sort_by="popular">
                  <label
                    for="popular"
                    class={"block px-1 cursor-pointer select-none rounded text-center hover:bg-purple-500 text-white #{if @sort_by == "popular", do: "bg-purple-500 font-bold", else: ""}"}
                  >
                    Popular
                  </label>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
