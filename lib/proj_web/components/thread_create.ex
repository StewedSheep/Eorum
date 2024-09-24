defmodule ProjWeb.PostFormComponent do
  use ProjWeb, :live_component

  alias Proj.Threads
  alias Proj.Threads.Thread

  def render(assigns) do
    ~H"""
    <div class="box-border p-4 border-4 rounded border-purple-900 bg-purple-800">
      <div class="flex items-center justify-between">
        <h1 class="text-white">Make a post</h1>

        <button
          data-collapse-target="collapse"
          class="rounded-md bg-pink-800 py-2 px-4 border border-transparent text-center text-sm text-white transition-all shadow-md hover:shadow-lg focus:bg-pink-700 focus:shadow-none active:bg-pink-700 hover:bg-pink-700 active:shadow-none disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none"
          type="button"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            class="w-4 h-4"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </button>
      </div>

      <div
        data-collapse="collapse"
        class="block h-0 w-full basis-full overflow-hidden transition-all duration-150 ease-in-out"
      >
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
      <script src="https://unpkg.com/@material-tailwind/html@latest/scripts/collapse.js">
      </script>
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
    params = Map.put(thread_params, "users_id", socket.assigns.current_user.id)

    case Threads.create_thread(params) do
      # happy path
      {:ok, _thread} ->
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

# TODO: KEEP COLLAPSE STATE ON FORM
# NOTE: NEED TO THINK IF SHOULD REDIRECT TO THE POST AFTER POSTING
