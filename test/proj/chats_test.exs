defmodule Proj.ChatsTest do
  use Proj.DataCase

  alias Proj.Chats

  describe "messages" do
    alias Proj.Chats.Forum

    import Proj.ChatsFixtures

    @invalid_attrs %{body: nil, sender: nil}

    test "list_messages/0 returns all messages" do
      forum = forum_fixture()
      assert Chats.list_messages() == [forum]
    end

    test "get_forum!/1 returns the forum with given id" do
      forum = forum_fixture()
      assert Chats.get_forum!(forum.id) == forum
    end

    test "create_forum/1 with valid data creates a forum" do
      valid_attrs = %{body: "some body", sender: "some sender"}

      assert {:ok, %Forum{} = forum} = Chats.create_forum(valid_attrs)
      assert forum.body == "some body"
      assert forum.sender == "some sender"
    end

    test "create_forum/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_forum(@invalid_attrs)
    end

    test "update_forum/2 with valid data updates the forum" do
      forum = forum_fixture()
      update_attrs = %{body: "some updated body", sender: "some updated sender"}

      assert {:ok, %Forum{} = forum} = Chats.update_forum(forum, update_attrs)
      assert forum.body == "some updated body"
      assert forum.sender == "some updated sender"
    end

    test "update_forum/2 with invalid data returns error changeset" do
      forum = forum_fixture()
      assert {:error, %Ecto.Changeset{}} = Chats.update_forum(forum, @invalid_attrs)
      assert forum == Chats.get_forum!(forum.id)
    end

    test "delete_forum/1 deletes the forum" do
      forum = forum_fixture()
      assert {:ok, %Forum{}} = Chats.delete_forum(forum)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_forum!(forum.id) end
    end

    test "change_forum/1 returns a forum changeset" do
      forum = forum_fixture()
      assert %Ecto.Changeset{} = Chats.change_forum(forum)
    end
  end
end
