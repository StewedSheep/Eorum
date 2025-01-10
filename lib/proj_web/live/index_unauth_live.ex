defmodule ProjWeb.IndexUnAuthLive do
  use ProjWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # defp get_user_from_session(session) do
  #   if user_token = session["user_token"] do
  #     Proj.Accounts.get_user_by_session_token(user_token)
  #   else
  #     nil
  #   end
  # end

  def render(assigns) do
    ~H"""

    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
