defmodule ProjWeb.IndexUnAuthLive do
  use ProjWeb, :live_view

  alias ProjWeb.Component.Accordion

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
      <.accordion>
        <.accordion_item>
          <.accordion_trigger group="my-group" open>
            Is it accessible?
          </.accordion_trigger>
          <.accordion_content>
            Yes. It adheres to the WAI-ARIA design pattern.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item>
          <.accordion_trigger group="my-group">
            Is it styled?
          </.accordion_trigger>
          <.accordion_content>
            Yes. It comes with default styles that matches the other components' aesthetic.
          </.accordion_content>
        </.accordion_item>
        <.accordion_item>
          <.accordion_trigger group="my-group">
            Is it animated?
          </.accordion_trigger>
          <.accordion_content>
            Yes. It's animated by default, but you can disable it if you prefer.
          </.accordion_content>
        </.accordion_item>
      </.accordion>

    """
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end
end
