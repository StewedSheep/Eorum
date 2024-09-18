defmodule ProjWeb.ThreadsLive do
  use ProjWeb, :live_view

  alias Proj.Threads
  alias Proj.Threads.Thread

  def mount(_params, _session, socket) do
    threads = Threads.list_threads()
    changeset = Threads.change_thread(%Thread{})

    socket =
      assign(socket,
        form: to_form(changeset),
        threads: threads
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Posts</h1>

    <.form for={@form} phx-submit="save">
      <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
      <.input field={@form[:body]} placeholder="Content" autocomplete="off" />
      <.button phx-disable-with="posting...">
        Post
      </.button>
    </.form>

    <div :for={thread <- @threads}>
      <p><%= thread.topic %></p>
    </div>
    """
  end

  def handle_event(
        "save",
        %{"thread" => thread_params},
        socket
      ) do
    # Add user id to param map
    thread_param = Map.merge(thread_params, %{"user_id" => socket.assigns.current_user.id})
    # create new thread
    case Threads.create_thread(thread_param) do
      # happy path
      {:ok, thread} ->
        # update existing threads list
        socket = update(socket, :threads, fn threads -> [thread | threads] end)

        changeset = Threads.change_thread(%Thread{})

        {:noreply, assign(socket, :form, to_form(changeset))}

      # sad path
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
