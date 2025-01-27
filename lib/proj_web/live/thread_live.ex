defmodule ProjWeb.IndexLive.ThreadLive do
  use ProjWeb, :live_component

  # alias Proj.Threads.{Comments}
  alias Proj.Threads

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def truncate_body(body) do
    body
    |> String.split("\n", trim: true)
    |> Enum.take(6)
    |> Enum.join("\n")
  end

  def handle_event("toggle_comment", _params, socket) do
    comment_toggle = if socket.assigns.comment_toggle == 1, do: 0, else: 1
    socket = assign(socket, comment_toggle: comment_toggle)
    {:noreply, socket}
  end

  # Adds the like to the database and then queries the db again for updated count of likes

  def handle_event("thread_like", %{"threads_id" => threads_id, "users_id" => users_id}, socket) do
    attrs = %{threads_id: threads_id, users_id: users_id, is_like: true}
    Threads.add_like(attrs)
    {:noreply, assign(socket, votes: Threads.get_likes_dislikes(threads_id, users_id))}
  end

  def handle_event(
        "thread_dislike",
        %{"threads_id" => threads_id, "users_id" => users_id},
        socket
      ) do
    attrs = %{threads_id: threads_id, users_id: users_id, is_like: true}
    Threads.add_dislike(attrs)
    {:noreply, assign(socket, votes: Threads.get_likes_dislikes(threads_id, users_id))}
  end

  # def handle_event(
  #       "comment_like",
  #       %{"comments_id" => comments_id, "users_id" => users_id},
  #       socket
  #     ) do
  #   attrs = %{comments_id: comments_id, users_id: users_id, is_like: true}
  # end

  # def handle_event(
  #       "comment_dislike",
  #       %{"comments_id" => comments_id, "users_id" => users_id},
  #       socket
  #     ) do
  #   attrs = %{comments_id: comments_id, users_id: users_id, is_like: true}
  # end

  def handle_event("save_comment", %{"comments" => comment_params}, socket) do
    attrs = Map.put(comment_params, "users_id", socket.assigns.current_user.id)

    case Threads.create_comment(attrs) do
      {:ok, comment} ->
        IO.inspect(comment, label: "comment")

        updated_thread = %{
          socket.assigns.thread
          | thread_comments: socket.assigns.thread.thread_comments ++ [comment]
        }

        {:noreply, assign(socket, thread: updated_thread, form: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def render(assigns) do
    ~H"""
        <div class="bg-[#F4F6D9] border-solid border rounded-lg mx-4 md:mx-auto my-4 max-w-md md:max-w-2xl">
        <%!-- <%= inspect(@votes) %> --%>
          <div class="flex items-start px-4 py-6">
            <div class="w-full">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-bold text-gray-900"><%= @thread.topic %></h2>
                <div class="text-sm text-gray-700 flex flex-col items-end">
                  <%= Map.get(@thread.users, :username, Map.get(@thread, :username)) || @thread.username  %>
                  <small class="text-sm text-gray-700">
                    <%= Calendar.strftime(@thread.inserted_at, "%H:%M %d %b %y") %>
                  </small>
                </div>
              </div>
              <p class="mt-3 text-gray-900 text-s"><%= truncate_body(@thread.body) |> String.replace("\n", "<br>") |> Phoenix.HTML.raw() %></p>
              <div class="mt-7 flex items-center justify-between">
              <div class="flex items-center space-y-2">
                  <.voting current_user={@current_user} votes={@votes} thread={@thread} target={@myself} entity="thread" />
                  <button phx-click={"toggle_comment"} phx-target={@myself} class="text-gray-700 mr-4">
                    <.icon name="hero-chat-bubble-left-right" class="w-6 h-6 mr-1" />
                    <span class="font-medium text-gray-700"><%= length(@thread.thread_comments) %> comments</span>
                  </button>
                </div>
                <div class="text-gray-700 text-sm">
                  <span class="font-medium mr-1">share</span>
                  <.icon name="hero-arrow-up-tray" class="w-6 h-6" />
                </div>
              </div>
            </div>
          </div>
          <.thread_comments current_user={@current_user} thread={@thread} comment_toggle={@comment_toggle}
          form={to_form(Threads.change_comment(%Threads.Comments{}))} target={@myself} />
        </div>
    """
  end

  def thread_comments(assigns) do
    ~H"""
    <div class={"border rounded-b-lg bg-gray-[##F4F6D9] overflow-y-auto relative transform transition-all duration-500 ease #{if @comment_toggle == 1, do: "max-h-[calc(100vh-600px)]", else: "max-h-0"}"}>
        <div class="flex flex-col flex-grow max-h-screen space-y-3 p-6">
          <%= for comment <- @thread.thread_comments do %>
            <div class="bg-[#fafbee] p-3 rounded-lg shadow-md">
                <h3 class="text-l font-semibold"><%= Proj.Accounts.get_username!(comment.users_id) %></h3>
                <p class="text-gray-700 text-sm mb-2"><%= Calendar.strftime(comment.inserted_at, "%d %b %y %H:%M") %></p>
                <p class="text-gray-700"><%= comment.body %>
                </p>
                <%!-- <.voting current_user={@current_user} votes={@votes}/> --%>
            </div>
          <% end %>


        </div>
        <.form for={@form} phx-target={@target} phx-submit="save_comment" class="sticky bottom-0 bg-[#fafbee] p-4 rounded-lg shadow-md">
                <div class="mb-4">
                    <label class="block text-gray-700 font-semibold mb-2" for="comment_body">
                        Comment
                    </label>
                    <.input id={"threads_id-#{@thread.id}"} field={@form[:threads_id]} type="hidden" value={@thread.id}/>
                    <.input id={"body-#{@thread.id}"} field={@form[:body]} placeholder="Your two cents..." autocomplete="off" type="textarea" phx-debounce="blur" />
                </div>
                <.button
                    class="buttons flex"
                    type="submit">
                    Submit
                </.button>
            </.form>
    </div>

    """
  end

  def voting(assigns) do
    ~H"""
    <div>
      <!-- Thumbs Up -->
      <button phx-click={@entity <> "_like"} phx-target={@target} phx-value-threads_id={@thread.id} phx-value-users_id={@current_user.id} class=" text-white rounded-full">
        <.icon name={if @votes.user_reaction == true, do: "hero-hand-thumb-up-solid", else: "hero-hand-thumb-up"}
        class={"w-6 h-6 mr-1 #{if @votes.user_reaction == true, do: "bg-green-500", else: "bg-gray-700"}"} />
      </button>
      <span class="font-medium text-gray-700 mr-4"><%= @votes.likes %></span>
      <!-- Thumbs Down -->
      <span class="font-medium text-gray-700 mr-1"><%= @votes.dislikes %></span>
      <button phx-click={@entity <> "_dislike"} phx-target={@target} phx-value-threads_id={@thread.id} phx-value-users_id={@current_user.id} class=" text-white rounded-full">
        <.icon name={if @votes.user_reaction == false, do: "hero-hand-thumb-down-solid", else: "hero-hand-thumb-down"}
        class={"w-6 h-6 mr-4 #{if @votes.user_reaction == false, do: "bg-red-500", else: "bg-gray-700"}"} />
      </button>
    </div>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
