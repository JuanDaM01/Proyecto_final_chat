defmodule ChatApp.Chat do
  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Chat.Room

  def list_rooms do
    Repo.all(Room)
  end

  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end
end
