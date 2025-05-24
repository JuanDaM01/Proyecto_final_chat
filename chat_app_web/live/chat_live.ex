defmodule ChatAppWeb.ChatLive do
  use Phoenix.LiveView
  alias ChatAppWeb.Presence

  @impl true
  def mount(params, _session, socket) do
    room = Map.get(params, "room", "lobby")
    username = Map.get(params, "username", "")
    topic = "chat_room:#{room}"

    socket =
      assign(socket,
        messages: [],
        message: "",
        username: username,
        users: [],
        room: room,
        topic: topic
      )

    if connected?(socket) and username != "" do
      {:ok, _} = Presence.track(self(), topic, username, %{})
      Phoenix.PubSub.subscribe(ChatApp.PubSub, topic)
      users = Presence.list(topic) |> Map.keys()
      {:ok, assign(socket, users: users)}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"room" => room} = params, _uri, socket) do
    username = Map.get(params, "username", socket.assigns.username || "")
    topic = "chat_room:#{room}"

    if connected?(socket) and username != "" do
      {:ok, _} = Presence.track(self(), topic, username, %{})
      Phoenix.PubSub.subscribe(ChatApp.PubSub, topic)
      users = Presence.list(topic) |> Map.keys()
      {:noreply, assign(socket,
        messages: [],
        users: users,
        room: room,
        topic: topic,
        username: username
      )}
    else
      {:noreply, assign(socket,
        messages: [],
        users: [],
        room: room,
        topic: topic,
        username: username
      )}
    end
  end

  @impl true
  def handle_event("send_message", %{"message" => msg}, socket) do
    time = NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_time() |> Time.to_string() |> String.slice(0,5)
    message = %{user: socket.assigns.username, text: msg, time: time}
    if socket.assigns.topic do
      Phoenix.PubSub.broadcast(ChatApp.PubSub, socket.assigns.topic, {:new_message, message})
    end
    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("update_message", %{"message" => msg}, socket) do
    {:noreply, assign(socket, message: msg)}
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
end
