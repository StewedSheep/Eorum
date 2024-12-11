defmodule Proj.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Proj.Chats` context.
  """

  @doc """
  Generate a forum.
  """
  def forum_fixture(attrs \\ %{}) do
    {:ok, forum} =
      attrs
      |> Enum.into(%{
        body: "some body",
        sender: "some sender",
        category: "some category"
      })
      |> Proj.Chats.create_forum()

    forum
  end

  @doc """
  Generate a forum.
  """
  def forum_fixture(attrs \\ %{}) do
    {:ok, forum} =
      attrs
      |> Enum.into(%{
        body: "some body",
        sender: "some sender"
      })
      |> Proj.Chats.create_forum()

    forum
  end
end
