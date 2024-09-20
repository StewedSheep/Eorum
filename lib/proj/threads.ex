defmodule Proj.Threads do
  import Ecto.Query, warn: false
  alias Proj.Repo

  alias Proj.Threads.Thread

  def list_threads do
    Repo.all(from t in Thread, order_by: [desc: t.id])
  end

  def create_thread(attrs \\ %{}) do
    %Thread{}
    |> Thread.changeset(attrs)
    |> Repo.insert()
  end

  def delete_thread(%Thread{} = thread) do
    Repo.delete(thread)
  end

  def change_thread(%Thread{} = thread, attrs \\ %{}) do
    Thread.changeset(thread, attrs)
  end
end
