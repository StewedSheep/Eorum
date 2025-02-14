defmodule ProjWeb.UserLoginLive do
  use ProjWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="space-t-20 pt-20">
      <div class="mx-auto max-w-sm bg-[#eed5aa]">
        <.header class="text-center">
          <a class="font-semibold text-brand">Log in to account</a>
          <br />
          <p class="text-sm">
            Don't have an account?
            <.link
              navigate={~p"/users/register"}
              class="font-semibold text-brand hover:underline text-pink-700"
            >
              Sign up
            </.link>
            for an account now.
          </p>
        </.header>
        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />

          <:actions>
            <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
            <.link href={~p"/users/reset_password"} class="text-sm font-semibold text-pink-700">
              Forgot your password?
            </.link>
          </:actions>
          <:actions>
            <.button phx-disable-with="Logging in..." class="w-full">
              Log in <span aria-hidden="true">→</span>
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
