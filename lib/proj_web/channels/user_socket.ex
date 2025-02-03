defmodule ProjWeb.UserSocket do
  use Phoenix.Socket
  require Logger

  alias Repo

  # A Socket handler
  #
  # It's possible to control the websocket connection and
  # assign values that can be accessed by your channel topics.

  ## Channels
  # Uncomment the following line to define a "room:*" topic
  # pointing to the `ProjWeb.RoomChannel`:
  #
  channel("user", ProjWeb.UsersChannel)
  channel("forum", ProjWeb.ForumChannel)
  #
  # To create a channel file, use the mix task:
  #
  #     mix phx.gen.channel Room
  #
  # See the [`Channels guide`](https://hexdocs.pm/phoenix/channels.html)
  # for further details.

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error` or `{:error, term}`. To control the
  # response the client receives in that case, [define an error handler in the
  # websocket
  # configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-websocket-configuration).
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.

  # def connect(%{"user_token" => user_token}, socket, _connect_info) do
  #   case Phoenix.Token.verify(socket, "user", user_token) do
  #     {:ok, user_id} ->
  #       {:ok, assign(socket, :user_id, user_id)}

  #     {:error, _} ->
  #       :error
  #   end
  # end

  def connect(%{"token" => token}, socket, _connect_info) do
    case verify(socket, token) do
      {:ok, user} ->
        socket = assign(socket, :user, user)
        {:ok, socket}

      {:error, _} ->
        :error
    end
  end

  def connect(_, _socket) do
    Logger.error("#{__MODULE__} connect error missing token")
    :error
  end

  # Socket IDs are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Elixir.ProjWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket),
    do: nil

  @one_day 86400
  defp verify(socket, token),
    do:
      Phoenix.Token.verify(
        socket,
        "SfCFXSVQqV",
        token,
        max_age: @one_day
      )
end
