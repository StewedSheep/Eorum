defmodule ProjWeb.IndexLive do
  use ProjWeb, :live_view

  alias ProjWeb.IndexLive.ThreadLive
  alias Proj.Threads.{Thread, ThreadLikes}

  @moduledoc """
  IndexLive is the parent view and landing page for logged in users
  """

  def mount(_params, _session, socket) do
    changeset = Thread.change_thread(%Thread{})

    {:ok,
     assign(socket,
       per_page: 10,
       sort_by: "newest",
       current_page: 1,
       total_pages: Thread.total_pages(10),
       threads: Thread.list_threads(1, 10, "newest"),
       form_toggle: "0",
       form: to_form(changeset)
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

  # Handles the live validation for the New Post form
  def handle_event("validate", %{"thread" => thread_params}, socket) do
    changeset =
      %Thread{}
      |> Thread.change_thread(thread_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # Toggles between open and closed state on New Post form

  def handle_event("toggle_post_form", _params, socket) do
    # Toggle form_toggle value between 0 and 1
    form_toggle = if socket.assigns.form_toggle == 1, do: 0, else: 1
    {:noreply, assign(socket, form_toggle: form_toggle)}
  end

  # Handles the "save" event from the New Post form
  # After submitting takes the form changeset and creates a new thread to prepend it to threads list
  # adds current username to the rendered thread, on db query queries for poster id then by asoc derives username

  def handle_event(
        "save",
        %{"thread" => thread_params},
        socket
      ) do
    params = Map.put(thread_params, "users_id", socket.assigns.current_user.id)

    case Thread.create_thread(params) do
      {:ok, _thread} ->
        {:noreply,
         assign(socket,
           form: to_form(Thread.change_thread(%Thread{}, %{})),
           threads:
             Thread.list_threads(
               socket.assigns.page,
               socket.assigns.per_page,
               socket.assigns.sort_by
             ),
           form_toggle: "0"
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  # Signal from thread_live to delete the thread from list of threads
  def handle_info({:delete_thread, thread_id}, socket) do
    updated_threads =
      Enum.filter(socket.assigns.threads, fn thread ->
        thread.id != String.to_integer(thread_id)
      end)

    {:noreply, assign(socket, :threads, updated_threads)}
  end

  @doc """
  Render for the New Post form
  """
  def thread_create(assigns) do
    ~H"""
    <div class=":form, to_form(rounded-lg mx-4 md:mx-auto max-w-md md:max-w-2xl rounded border-purple-600 border-2 bg-purple-800">
      <ul class="shadow-box">
        <!-- Dropdown form trigger -->
        <button type="button" class="w-full px-2 py-2 text-left" phx-click="toggle_post_form">
          <div class="flex items-center justify-between mx-3">
            <span class="font-medium text-slate-100 my-3">
              New Post
            </span>
            <!-- Arrow SVG -->
            <.icon
              name="hero-chevron-down"
              class={"w-6 h-6 text-slate-100 transition-all #{if @form_toggle == 1, do: "rotate-180", else: ""}"}
            />
          </div>
        </button>
        <!-- Dropdown form -->
        <div class={"relative overflow-hidden transition-all duration-500 #{if @form_toggle == 1, do: "max-h-screen", else: "max-h-0"}"}>
          <div class="p-3">
            <.form for={@form} phx-submit="save" phx-change="validate">
              <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
              <.input
                field={@form[:body]}
                placeholder="Content"
                autocomplete="off"
                type="textarea"
                phx-debounce="blur"
              />
              <.button
                class="buttons flex"
                style="margin-top: 10px; margin-right: 10px;"
                phx-disable-with="posting..."
              >
                Post
              </.button>
            </.form>
          </div>
        </div>
      </ul>
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

  def render(assigns) do
    ~H"""
    <div class="space-t-4 pt-10">
      <.thread_create current_user={@current_user} form_toggle={@form_toggle} form={@form} />
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
          current_user={@current_user}
          thread={thread}
          show_full={false}
          comment_toggle="0"
          show_thread_delete_modal={false}
          thread_votes={ThreadLikes.get_thread_votes(thread.id, @current_user.id)}
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

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
