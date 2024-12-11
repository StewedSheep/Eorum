defmodule ProjWeb.ThreadCreateComponent do
  use ProjWeb, :live_component

  alias Proj.Threads
  alias Proj.Threads.Thread

  import SaladUI.Accordion

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
      {:ok, thread} ->
        # update existing threads list in parent view
        send(self(), {:new_thread_signal, Map.put(thread, :username, socket.assigns.current_user.username)})
        #Clears form after operations complete
        {:noreply, assign(socket, :form, to_form(Threads.change_thread(%Thread{})))}

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

  def render(assigns) do
    ~H"""
    <div class="box-border p-4 rounded-lg mx-4 md:mx-auto max-w-md md:max-w-2xl rounded border-purple-600 border-2 bg-purple-800">
    <.accordion>
    <.accordion_item>
    <.accordion_trigger group="my-group">
      <div class="flex items-center justify-between">
      Is it accessible?
      </div>
    </.accordion_trigger>
      <.accordion_content>
        <.form for={@form} phx-submit="save" phx-change="validate" phx-target={@myself}>
          <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
          <.input field={@form[:body]} placeholder="Content" autocomplete="off" type="textarea" phx-debounce="blur" />
          <.button
            class="buttons flex"
            style="margin-top: 10px; margin-right: 10px;"
            phx-disable-with="posting..."
          >
            Post
          </.button>
        </.form>
        </.accordion_content>
      </.accordion_item>
      </.accordion>
      </div>
    """
  end
end

# NOTE: NEED TO THINK IF SHOULD REDIRECT TO THE POST AFTER POSTING
