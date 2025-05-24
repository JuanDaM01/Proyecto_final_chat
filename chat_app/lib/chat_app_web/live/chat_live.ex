defmodule ChatAppWeb.ChatLive do
  use Phoenix.LiveView
  alias ChatAppWeb.Presence
  alias ChatApp.Storage

  @impl true
  def mount(params, _session, socket) do
    # Autenticación básica: si no hay usuario, redirige al lobby
    username = Map.get(params, "username", "")
    if username == "" do
      {:ok, push_navigate(socket, to: "/")}
    else
      room = Map.get(params, "room", "lobby")
      topic = "chat_room:#{room}"
      messages = Storage.load_messages(room)

      if connected?(socket) do
        Phoenix.PubSub.subscribe(ChatApp.PubSub, topic)
        {:ok, _} = Presence.track(self(), topic, username, %{})
        users = Presence.list(topic) |> Map.keys()
        {:ok, assign(socket,
          messages: Enum.map(messages, &parse_message/1),
          message: "",
          username: username,
          users: users,
          room: room,
          topic: topic
        )}
      else
        {:ok, assign(socket,
          messages: Enum.map(messages, &parse_message/1),
          message: "",
          username: username,
          users: [],
          room: room,
          topic: topic
        )}
      end
    end
  end

  # Agrupa todas las cláusulas de handle_event/3 aquí:
  @impl true
  def handle_event("send_message", %{"message" => msg}, socket) do
    time = NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time() |> Time.to_string() |> String.slice(0,5)
    message = %{user: socket.assigns.username, text: msg, time: time}
    if socket.assigns.topic do
      Phoenix.PubSub.broadcast(ChatApp.PubSub, socket.assigns.topic, {:new_message, message})
    end
    # Guardar mensaje en archivo
    ChatApp.Storage.save_message(socket.assigns.room, "#{message.time}|#{message.user}|#{message.text}")
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("update_message", %{"message" => msg}, socket) do
    {:noreply, assign(socket, message: msg)}
  end

  @impl true
  def handle_event("show_history", _params, socket) do
    messages = Storage.load_messages(socket.assigns.room, 100)
    parsed = Enum.map(messages, &parse_message/1)
    {:noreply, assign(socket, messages: parsed)}
  end

  def handle_event("search_messages", %{"query" => query}, socket) do
    found = Storage.search_messages(socket.assigns.room, query)
    parsed = Enum.map(found, &parse_message/1)
    {:noreply, assign(socket, messages: parsed)}
  end

  @impl true
  def handle_event("leave_room", _params, socket) do
    {:noreply, push_navigate(socket, to: "/")}
  end

  @impl true
  def handle_info({:new_message, msg}, socket) do
    messages = socket.assigns.messages ++ [msg]
    {:noreply, assign(socket, messages: messages)}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    users = Presence.list(socket.assigns.topic) |> Map.keys()
    {:noreply, assign(socket, users: users)}
  end

  defp parse_message(line) do
    case String.split(line, "|", parts: 3) do
      [time, user, text] -> %{time: time, user: user, text: text}
      _ -> %{time: "", user: "", text: line}
    end
  end
end
