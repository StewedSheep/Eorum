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

    <.form for={@form} phx-submit="save" phx-change="validate">
      <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
      <.input field={@form[:body]} placeholder="Content" autocomplete="off" phx-debounce="blur" />
      <.button class="buttons flex" phx-disable-with="posting...">
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
    # create new thread
    params = Map.put(thread_params, "user_id", socket.assigns.current_user.id)
    IO.inspect(params, label: "combined params")

    case Threads.create_thread(params) do
      # happy path
      {:ok, thread} ->
        # update existing threads list
        socket = update(socket, :threads, fn threads -> [thread | threads] end)

        changeset = Threads.change_thread(%Thread{}, params)

        {:noreply, assign(socket, :form, to_form(changeset))}

      # sad path
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("validate", %{"thread" => thread_params}, socket) do
    changeset =
      %Thread{}
      |> Threads.change_thread(thread_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end
end
