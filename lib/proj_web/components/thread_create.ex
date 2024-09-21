defmodule ProjWeb.PostFormComponent do
  use ProjWeb, :live_component

  alias Proj.Threads
  alias Proj.Threads.Thread

  def render(assigns) do
    ~H"""
    <div class="box-border p-4 border-4 rounded border-purple-900 bg-purple-800">
      <h1>Posts</h1>

      <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
        <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
        <.input field={@form[:body]} placeholder="Content" autocomplete="off" phx-debounce="blur" />
        <.button
          class="buttons flex"
          style="margin-top: 10px; margin-right: 10px;"
          phx-disable-with="posting..."
        >
          Post
        </.button>
      </.form>
    </div>
    """
  end

  def mount(socket) do
    changeset = Threads.change_thread(%Thread{})

    socket =
      assign(socket,
        form: to_form(changeset)
      )

    {:ok, socket}
  end

  def handle_event(
        "save",
        %{"thread" => thread_params},
        socket
      ) do
    # create new thread
    params = Map.put(thread_params, "user_id", socket.assigns.current_user.id)

    case Threads.create_thread(params) do
      # happy path
      {:ok, _thread} ->
        # NOTE: NEED TO THINK IF SHOULD REDIRECT TO THE POST AFTER POSTING
        # update existing threads list
        # socket = update(socket, :threads, fn threads -> [thread | threads] end)

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
