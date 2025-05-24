defmodule ChatServer.RoomManager do
  use GenServer

  # Estado: %{sala => MapSet de usuarios}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def create_room(room), do: GenServer.call(__MODULE__, {:create, room})
  def join_room(room, user), do: GenServer.call(__MODULE__, {:join, room, user})
  def leave_room(room, user), do: GenServer.call(__MODULE__, {:leave, room, user})
  def list_rooms, do: GenServer.call(__MODULE__, :list)
  def users_in_room(room), do: GenServer.call(__MODULE__, {:users, room})
  def save_message(room, username, message), do: GenServer.cast(__MODULE__, {:save_message, room, username, message})
  def get_history(room, lines \\ 20), do: GenServer.call(__MODULE__, {:get_history, room, lines})

  # Callbacks
  def init(state), do: {:ok, state}

  def handle_call({:create, room}, _from, state) do
    if Map.has_key?(state, room) do
      {:reply, {:error, :exists}, state}
    else
      {:reply, :ok, Map.put(state, room, MapSet.new())}
    end
  end

  def handle_call({:join, room, user}, _from, state) do
    case Map.get(state, room) do
      nil -> {:reply, {:error, :not_found}, state}
      users ->
        new_users = MapSet.put(users, user)
        {:reply, :ok, Map.put(state, room, new_users)}
    end
  end

  def handle_call({:leave, room, user}, _from, state) do
    case Map.get(state, room) do
      nil -> {:reply, {:error, :not_found}, state}
      users ->
        new_users = MapSet.delete(users, user)
        {:reply, :ok, Map.put(state, room, new_users)}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_call({:users, room}, _from, state) do
    {:reply, Map.get(state, room, MapSet.new()) |> MapSet.to_list(), state}
  end

  def handle_cast({:save_message, room, username, message}, state) do
    timestamp = :calendar.local_time() |> NaiveDateTime.from_erl!() |> NaiveDateTime.to_string()
    line = "[#{timestamp}] #{username}: #{message}\n"
    file = "chat_history_#{room}.txt"
    File.write(file, line, [:append])
    {:noreply, state}
  end

  def handle_call({:get_history, room, lines}, _from, state) do
    file = "chat_history_#{room}.txt"
    if File.exists?(file) do
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.take(-lines)
      |> Enum.join("\n")
      |> then(&{:reply, &1, state})
    else
      {:reply, "No hay historial para esta sala.", state}
    end
  end
end
