defmodule ProjWeb.ThreadsLive do
  use ProjWeb, :live_view

  alias ProjWeb.PostFormComponent
  alias Proj.Threads

  def mount(_params, _session, socket) do
    threads = Threads.list_threads()

    socket =
      assign(socket,
        threads: threads
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={PostFormComponent} id={:new} current_user={@current_user} />

    <%!-- thread list --%>
    <div :for={thread <- @threads}>
      <p><%= thread.topic %></p>
    </div>
    """
  end
end
