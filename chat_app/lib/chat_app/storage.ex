defmodule ChatApp.Storage do
  @users_file "persisted_users.txt"
  @rooms_file "persisted_rooms.txt"

  def register_user(username, password) do
    users = load_users()
    if Enum.any?(users, fn {u, _} -> u == username end) do
      {:error, :user_exists}
    else
      File.write!(@users_file, "#{username}|#{password}\n", [:append])
      :ok
    end
  end

  def authenticate_user(username, password) do
    users = load_users()
    Enum.any?(users, fn {u, p} -> u == username and p == password end)
  end

  def load_users do
    if File.exists?(@users_file) do
      File.read!(@users_file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        case String.split(line, "|", parts: 2) do
          [u, p] -> {u, p}
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)
    else
      []
    end
  end

  def save_room(room, password \\ "") do
    rooms = load_rooms()
    unless Enum.any?(rooms, fn {r, _} -> r == room end) do
      File.write!(@rooms_file, "#{room}|#{password}\n", [:append])
    end
  end

  def load_rooms do
    if File.exists?(@rooms_file) do
      File.read!(@rooms_file)
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        case String.split(line, "|", parts: 2) do
          [r, p] -> {r, p}
          [r] -> {r, ""}
        end
      end)
    else
      [{"lobby", ""}, {"general", ""}]
    end
  end

  def room_password(room) do
    load_rooms()
    |> Enum.find(fn {r, _} -> r == room end)
    |> case do
      {_, pass} -> pass
      _ -> ""
    end
  end

  def delete_room(room) do
    rooms = load_rooms() |> Enum.reject(fn {r, _} -> r == room end)
    File.write!(@rooms_file, Enum.map_join(rooms, "\n", fn {r, p} -> "#{r}|#{p}" end))
    File.rm("messages_#{room}.txt")
  end

  def load_messages(room, limit \\ 50) do
    file = "messages_#{room}.txt"
    if File.exists?(file) do
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.take(-limit)
    else
      []
    end
  end

  def search_messages(room, query) do
    file = "messages_#{room}.txt"
    if File.exists?(file) do
      File.read!(file)
      |> String.split("\n", trim: true)
      |> Enum.filter(&(String.contains?(&1, query)))
    else
      []
    end
  end

  def save_message(room, message) do
    file = "messages_#{room}.txt"
    File.write!(file, message <> "\n", [:append])
  end
end
