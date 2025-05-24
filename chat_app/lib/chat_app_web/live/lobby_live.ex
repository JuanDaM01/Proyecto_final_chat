defmodule ChatAppWeb.LobbyLive do
  use Phoenix.LiveView
  alias ChatApp.Storage

  def mount(_params, _session, socket) do
    rooms = Storage.load_rooms()
    {:ok, assign(socket, username: "", room: "", error: nil, rooms: rooms)}
  end

  def handle_event("set_username", %{"room" => room, "room_password" => room_password, "username" => username}, socket) do
    case Enum.find(socket.assigns.rooms, fn {r, _} -> r == room end) do
      {^room, pass} ->
        if pass == "" or pass == room_password do
          {:noreply, push_navigate(socket, to: "/chat/#{room}?username=#{URI.encode(username)}")}
        else
          {:noreply, assign(socket, error: "Contraseña de sala incorrecta")}
        end
      _ ->
        {:noreply, assign(socket, error: "Sala no encontrada")}
    end
  end

  def handle_event("create_room", %{"new_room" => new_room}, socket) do
    new_room = String.trim(new_room)
    cond do
      new_room == "" ->
        {:noreply, assign(socket, error: "El nombre de la sala es obligatorio")}
      new_room in Enum.map(socket.assigns.rooms, fn {r, _} -> r end) ->
        {:noreply, assign(socket, error: "La sala ya existe")}
      true ->
        Storage.save_room(new_room)
        rooms = Storage.load_rooms()
        {:noreply, assign(socket, rooms: rooms, error: nil)}
    end
  end

  def handle_event("delete_room", %{"room" => room}, socket) do
    Storage.delete_room(room)
    rooms = Storage.load_rooms()
    {:noreply, assign(socket, rooms: rooms)}
  end
end
