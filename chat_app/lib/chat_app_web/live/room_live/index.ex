defmodule ChatAppWeb.RoomLive.Index do
  use ChatAppWeb, :live_view
  alias ChatApp.Chat

  def mount(_params, _session, socket) do
    {:ok, assign(socket, rooms: Chat.list_rooms(), room_name: "")}
  end

  def handle_event("create_room", %{"room_name" => room_name}, socket) do
    case Chat.create_room(%{name: room_name}) do
      {:ok, _room} ->
        {:noreply, assign(socket, rooms: Chat.list_rooms(), room_name: "")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "No se pudo crear la sala")}
    end
  end

  def handle_event("update_room_name", %{"value" => value}, socket) do
    {:noreply, assign(socket, room_name: value)}
  end
end
