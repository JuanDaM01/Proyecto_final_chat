defmodule ChatAppWeb.ChatChannel do
  use ChatAppWeb, :channel

  def join("room:" <> _room_name, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("message:new", %{"user" => user, "body" => body}, socket) do
    broadcast!(socket, "message:new", %{
      user: user,
      body: body,
      timestamp: DateTime.utc_now() |> DateTime.to_string()
    })

    {:noreply, socket}
  end
end
