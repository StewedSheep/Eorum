defmodule ProjWeb.IndexLive.ThreadLive do
  use ProjWeb, :live_component

  alias Proj.Threads.{ThreadLikes, Comments, CommentLikes, Thread}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event(
        "save_comment",
        %{"comments" => comment_params, "threads_id" => threads_id},
        socket
      ) do
    attrs =
      Map.put(comment_params, "users_id", socket.assigns.current_user.id)
      |> Map.put("threads_id", threads_id)

    IO.inspect(attrs, label: "comment_params")

    case Comments.create_comment(attrs) do
      {:ok, comment} ->
        updated_thread = %{
          socket.assigns.thread
          | thread_comments: socket.assigns.thread.thread_comments ++ [comment]
        }

        {:noreply, assign(socket, thread: updated_thread, form: nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event(
        "delete_comment",
        %{"comment_id" => comment_id, "users_id" => users_id},
        socket
      ) do
    if socket.assigns.current_user.id == String.to_integer(users_id) do
      Comments.delete_comment_by_id(comment_id)
      # Remove the deleted comment from the thread's comment list
      updated_comments =
        Enum.reject(socket.assigns.thread.thread_comments, fn comment ->
          comment.id == String.to_integer(comment_id)
        end)

      IO.inspect(updated_comments, label: "updated_comments")

      # Update the thread with the new comment list
      {:noreply,
       assign(socket, thread: %{socket.assigns.thread | thread_comments: updated_comments})}
    else
      {:noreply, socket}
    end
  end

  def handle_event("toggle_thread_delete_modal", _params, socket) do
    # Toggle the show_thread_delete_modal state
    {:noreply, assign(socket, show_thread_delete_modal: !socket.assigns.show_thread_delete_modal)}
  end

  def handle_event("toggle_content", _params, socket) do
    {:noreply, assign(socket, show_full: !socket.assigns.show_full)}
  end

  def handle_event("toggle_comment", _params, socket) do
    comment_toggle = if socket.assigns.comment_toggle == 1, do: 0, else: 1
    socket = assign(socket, comment_toggle: comment_toggle)
    {:noreply, socket}
  end

  def handle_event("delete_thread", %{"thread_id" => threads_id, "users_id" => users_id}, socket) do
    if socket.assigns.current_user.id == String.to_integer(users_id) do
      Thread.delete_thread_by_id(threads_id)
      # Send parent view signal to rerender the threads list
      send(self(), {:delete_thread, threads_id})
      {:noreply, socket}
    end

    {:noreply, socket}
  end

  # Adds the like to the database and then queries the db again for updated count of likes
  def handle_event("thread_like", %{"entity_id" => threads_id, "users_id" => users_id}, socket) do
    attrs = %{threads_id: threads_id, users_id: users_id}
    ThreadLikes.add_like(attrs)
    {:noreply, assign(socket, thread_votes: ThreadLikes.get_thread_votes(threads_id, users_id))}
  end

  def handle_event(
        "thread_dislike",
        %{"entity_id" => threads_id, "users_id" => users_id},
        socket
      ) do
    attrs = %{threads_id: threads_id, users_id: users_id}

    ThreadLikes.add_dislike(attrs)
    {:noreply, assign(socket, thread_votes: ThreadLikes.get_thread_votes(threads_id, users_id))}
  end

  def handle_event("comment_like", %{"entity_id" => comments_id, "users_id" => users_id}, socket) do
    attrs = %{comments_id: comments_id, users_id: users_id}
    # add the like to the db
    CommentLikes.add_like(attrs)

    # Get updated comment votes
    updated_comments =
      update_comment_votes(
        socket.assigns.thread.thread_comments,
        comments_id,
        users_id
      )

    # Update the thread with updated comments
    updated_thread = %{socket.assigns.thread | thread_comments: updated_comments}

    {:noreply,
     socket
     |> assign(thread: updated_thread)}
  end

  def handle_event(
        "comment_dislike",
        %{"entity_id" => comments_id, "users_id" => users_id},
        socket
      ) do
    attrs = %{comments_id: comments_id, users_id: users_id}
    # Add dislike to the db
    CommentLikes.add_dislike(attrs)

    # Get updated comment votes
    updated_comments =
      update_comment_votes(
        socket.assigns.thread.thread_comments,
        comments_id,
        users_id
      )

    # Update the thread with updated comments
    updated_thread = %{socket.assigns.thread | thread_comments: updated_comments}

    {:noreply,
     socket
     |> assign(thread: updated_thread)}
  end

  defp update_comment_votes(comments, comments_id, users_id) do
    Enum.map(comments, fn comment ->
      if comment.id == String.to_integer(comments_id) do
        %{comment | comment_likes: CommentLikes.get_comment_votes(comments_id, users_id)}
      else
        comment
      end
    end)
  end

  def truncate_rows(string) do
    lines = String.split(string, "\n")
    first_8_lines = Enum.take(lines, 8)
    Enum.join(first_8_lines, "\n")
  end

  def render(assigns) do
    ~H"""
    <div class="bg-[#F4F6D9] border rounded-lg mx-4 md:mx-auto my-4 max-w-md md:max-w-2xl">
      <%!-- <%= inspect(@thread) %> --%>
      <div class="flex items-start px-4 py-6">
        <div class="w-full">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-bold text-gray-900">{@thread.topic}</h2>
            <div class="text-sm text-gray-700 flex flex-col items-end">
              {Map.get(@thread.users, :username, Map.get(@thread, :username)) || @thread.username}
              <small class="text-sm text-gray-700">
                {Calendar.strftime(@thread.inserted_at, "%H:%M %d %b %y")}
              </small>
            </div>
          </div>
          <%!-- Content of thread --%>
          <p class="mt-3 text-gray-900 text-s">
            <%!--  Checks if thread.body contains more than 500 characters or 8 newlines and then truncates if true --%>
            <%= if (String.length(@thread.body) > 500 or (String.graphemes(@thread.body) |> Enum.count(&(&1 == "\n")) > 8)) and not @show_full do %>
              {@thread.body
              |> String.slice(0..500)
              |> truncate_rows()
              |> String.replace("\n", "<br>")
              |> Phoenix.HTML.raw()}
            <% else %>
              {@thread.body |> String.replace("\n", "<br>") |> Phoenix.HTML.raw()}
            <% end %>
          </p>

          <%= if String.length(@thread.body) > 500 or (String.graphemes(@thread.body) |> Enum.count(&(&1 == "\n")) > 8) do %>
            <button
              phx-click="toggle_content"
              phx-target={@myself}
              class="text-blue-600 hover:text-blue-800 text-sm font-medium mt-2"
            >
              {if @show_full, do: "Show Less", else: "Show More"}
            </button>
          <% end %>
          <div class="mt-7 flex items-center justify-between">
            <div class="flex items-center">
              <%!-- Thread voting --%>
              <.voting
                entity="thread"
                current_user={@current_user}
                votes={@thread_votes}
                eid={@thread.id}
                target={@myself}
              />
              <%!-- Comment counter with toggle button --%>
              <button phx-click="toggle_comment" phx-target={@myself} class="text-gray-700">
                <.icon name="hero-chat-bubble-left-right" class="w-6 h-6 mr-1" />
                <span class="font-medium text-gray-700">
                  {length(@thread.thread_comments)} comments
                </span>
              </button>
            </div>
            <%!-- Delete thread button --%>
            <div>
              <%= if @thread.users_id == @current_user.id do %>
                <button
                  phx-click="toggle_thread_delete_modal"
                  phx-target={@myself}
                  class="border-2 rounded-lg p-1 border-red-400 text-gray-700 hover:bg-red-300"
                >
                  <.icon name="hero-trash" class="w-6 h-6" />
                </button>
                <!-- The delete modal -->
                <%= if @show_thread_delete_modal do %>
                  <.delete_thread_modal
                    id="delete-modal"
                    myself={@myself}
                    thread={@thread}
                    current_user={@current_user}
                  />
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
      <.thread_comments
        current_user={@current_user}
        thread={@thread}
        comment_votes={}
        comment_toggle={@comment_toggle}
        form={to_form(Comments.change_comment(%Comments{}))}
        target={@myself}
      />
    </div>
    """
  end

  def thread_comments(assigns) do
    ~H"""
    <div class={"border rounded-b-lg bg-gray-[#F4F6D9] overflow-y-auto relative transform transition-all duration-500 #{if @comment_toggle == 1, do: "max-h-[calc(100vh-600px)]", else: "max-h-0 opacity-0"}"}>
      <%= if @current_user.id != 0 do %>
        <.form
          for={@form}
          phx-target={@target}
          phx-submit="save_comment"
          phx-value-threads_id={@thread.id}
          class="sticky top-0 z-10 bg-[#fafbee] p-4 rounded-lg shadow-md"
        >
          <div class="mb-2">
            <div class="flex justify-between">
              <label class="block text-gray-700 font-semibold" for="comment_body">
                Comment
              </label>
              <.button class="buttons flex" type="submit">
                Submit
              </.button>
            </div>
            <%!-- <input
              id={"threads_id-#{@thread.id}"}
              field={@form[:threads_id]}
              value={@thread.id}
              class="hidden"
            /> --%>
            <.input
              id={"body-#{@thread.id}"}
              field={@form[:body]}
              placeholder="Your two cents..."
              autocomplete="off"
              type="textarea"
              phx-debounce="blur"
            />
          </div>
        </.form>
      <% end %>
      <div class="flex flex-col flex-grow max-h-screen space-y-3 p-6">
        <%!-- Case for no comments --%>
        <div
          id={"comments-empty-#{@thread.id}"}
          class="only:block hidden justify-center w-full text-center text-gray-600"
        >
          <p colspan="2">No comments</p>
        </div>

        <%= for comment <- @thread.thread_comments do %>
          <div class="bg-[#fafbee] p-3 rounded-lg shadow-md">
            <div class="flex justify-between">
              <div>
                <h3 class="text-l font-semibold">{Proj.Accounts.get_username!(comment.users_id)}</h3>
                <p class="text-gray-700 text-sm mb-2">
                  {Calendar.strftime(comment.inserted_at, "%d %b %y %H:%M")}
                </p>
              </div>
              <%!-- Delete Comment button --%>
              <%= if comment.users_id == @current_user.id do %>
                <div class="relative group">
                  <!-- Button to trigger the menu on hover -->
                  <button
                    class="h-9 w-9 border-2 rounded-lg p-1 border-red-400 text-gray-700 z-10"
                    disabled
                  >
                    <.icon name="hero-trash" class="w-6 h-6" />
                  </button>

    <!-- The sliding menu -->
                  <div
                    id={"menu-#{comment.id}"}
                    phx-click="delete_comment"
                    phx-value-comment_id={comment.id}
                    phx-value-users_id={@current_user.id}
                    phx-target={@target}
                    class="bg-[#fafbee] border-red-400 border-2 border-r-0 rounded-l-lg absolute right-7 top-0 ml-2 p-1 h-9 w-28 invisible transform transition-all group-hover:visible"
                  >
                    <button>Delete</button>
                  </div>
                </div>
                <%!-- <button phx-click="toggle_comment_delete" phx-target={@target} class="h-9 w-9 border-2 rounded-lg p-1 border-red-400 text-gray-700 hover:bg-red-300"> --%>
                <%!-- <.icon name="hero-trash" class="w-6 h-6" /> --%>
                <%!-- </button> --%>
              <% end %>
            </div>
            <p class="text-gray-700">{comment.body}</p>
            <div class="text-xs text-gray-500 mt-2">
              <%!-- <%= inspect(comment) %> --%>
            </div>
            <.voting
              id={"comment-votes-#{comment.id}"}
              phx-update="replace"
              entity="comment"
              current_user={@current_user}
              eid={comment.id}
              target={@target}
              votes={CommentLikes.get_comment_votes(comment.id, @current_user.id)}
            />
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def voting(assigns) do
    ~H"""
    <div>
      <!-- Thumbs Up -->
      <button
        phx-click={@entity <> "_like"}
        phx-target={@target}
        phx-value-entity_id={@eid}
        phx-value-users_id={@current_user.id}
        class=" text-white rounded-full"
        disabled={@current_user.id == 0}
      >
        <.icon
          name={
            if @votes.user_reaction == true,
              do: "hero-hand-thumb-up-solid",
              else: "hero-hand-thumb-up"
          }
          class={"w-6 h-6 mr-1 #{if @votes.user_reaction == true, do: "bg-green-500", else: "bg-gray-700"}"}
        />
      </button>
      <span class="font-medium text-gray-700 mr-4">{@votes.likes}</span>
      <!-- Thumbs Down -->
      <span class="font-medium text-gray-700 mr-1">{@votes.dislikes}</span>
      <button
        phx-click={@entity <> "_dislike"}
        phx-target={@target}
        phx-value-entity_id={@eid}
        phx-value-users_id={@current_user.id}
        class=" text-white rounded-full"
        disabled={@current_user.id == 0}
      >
        <.icon
          name={
            if @votes.user_reaction == false,
              do: "hero-hand-thumb-down-solid",
              else: "hero-hand-thumb-down"
          }
          class={"w-6 h-6 mr-4 #{if @votes.user_reaction == false, do: "bg-red-500", else: "bg-gray-700"}"}
        />
      </button>
    </div>
    """
  end

  def delete_thread_modal(assigns) do
    ~H"""
    <div
      id={@id}
      class="z-20 fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center"
    >
      <div class="bg-white p-6 rounded-lg shadow-xl mx-4">
        <h3 class="text-lg font-medium mb-4">Confirm Deletion</h3>
        <p class="text-gray-600 mb-6">
          Are you sure you want to delete this item? This action cannot be undone.
        </p>

        <div class="flex justify-end space-x-3">
          <button
            phx-click="toggle_thread_delete_modal"
            phx-target={@myself}
            class="px-4 py-2 border border-gray-300 rounded text-gray-700 hover:bg-gray-50"
          >
            Cancel
          </button>
          <button
            phx-click="delete_thread"
            phx-value-thread_id={@thread.id}
            phx-value-users_id={@current_user.id}
            phx-target={@myself}
            class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600"
          >
            Delete
          </button>
        </div>
      </div>
    </div>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
