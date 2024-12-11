defmodule ProjWeb.Plugs.PutUserToken do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "SfCFXSVQqV", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
