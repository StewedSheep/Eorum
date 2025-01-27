defmodule ProjWeb.IndexLive do
  use ProjWeb, :live_view

  alias ProjWeb.IndexLive.ThreadLive
  alias Proj.Threads.Thread
  alias Proj.Threads

  @moduledoc """
  IndexLive is the parent view and landing page for logged in users
  """

  def mount(_params, _session, socket) do
    changeset = Threads.change_thread(%Thread{})

    {:ok,
     assign(socket,
       threads: Threads.list_threads(),
       selected: "0",
       form: to_form(changeset)
     )}
  end

  # Handles the live validation for the New Post form

  def handle_event("validate", %{"thread" => thread_params}, socket) do
    changeset =
      %Thread{}
      |> Threads.change_thread(thread_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  # Toggles between open and closed state on New Post form

  def handle_event("toggle_post_form", _params, socket) do
    # Toggle selected value between 0 and 1
    selected = if socket.assigns.selected == 1, do: 0, else: 1
    {:noreply, assign(socket, selected: selected)}
  end

  # Handles the "save" event from the New Post form
  # After submitting takes the form changeset and creates a new thread to prepend it to threads list
  # adds current username to the rendered thread, on db query queries for poster id then by asoc derives username

  def handle_event(
        "save",
        %{"thread" => thread_params},
        socket
      ) do
    # add user id to params
    params = Map.put(thread_params, "users_id", socket.assigns.current_user.id)

    case Threads.create_thread(params) do
      # happy path
      {:ok, thread} ->
        Map.put(thread, :username, socket.assigns.current_user.username)
        socket = update(socket, :threads, fn threads -> [thread | threads] end)
        changeset = Threads.change_thread(%Thread{}, params)

        {:noreply, assign(socket, :form, to_form(changeset))}

      # sad path
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
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
            <div class="flex items-center justify-between">
              <span class="font-medium text-slate-100 my-3">
                New Post
              </span>
              <!-- Arrow SVG -->
              <.icon name="hero-chevron-down" class={"w-6 h-6 text-slate-100 transition-all #{if @selected == 1, do: "rotate-180", else: ""}"} />
            </div>
          </button>
          <!-- Dropdown form -->
          <div class={"relative overflow-hidden transition-all duration-500 #{if @selected == 1, do: "max-h-screen", else: "max-h-0"}"}>
            <div class="p-3">
              <.form for={@form} phx-submit="save" phx-change="validate">
                <.input field={@form[:topic]} placeholder="Title" autocomplete="off" />
                <.input field={@form[:body]} placeholder="Content" autocomplete="off" type="textarea" phx-debounce="blur" />
                <.button class="buttons flex" style="margin-top: 10px; margin-right: 10px;" phx-disable-with="posting...">
                  Post
                </.button>
              </.form>
            </div>
          </div>
        </ul>
      </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div class="space-t-4 pt-10">
      <.thread_create current_user={@current_user} selected={@selected} form={@form} />
      <%!-- thread list --%>
      <%= for thread <- @threads do %>
      <%!-- <%= inspect(thread) %> --%>
      <.live_component module={ThreadLive} id={thread.id} votes={Threads.get_likes_dislikes(thread.id, @current_user.id)} current_user={@current_user} thread={thread} comment_toggle="0" />
      <% end %>
      </div>
    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
