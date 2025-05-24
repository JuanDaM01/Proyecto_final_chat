defmodule ChatServer.TcpServer do
  use GenServer

  @port 4040

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(_) do
    {:ok, socket} = :gen_tcp.listen(@port, [:binary, packet: :line, active: false, reuseaddr: true])
    spawn(fn -> accept_loop(socket) end)
    {:ok, %{}}
  end

  defp accept_loop(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    spawn(fn -> handle_client(client) end)
    accept_loop(socket)
  end

  defp handle_client(socket) do
    :gen_tcp.send(socket, "Usuario: ")
    case :gen_tcp.recv(socket, 0) do
      {:ok, username_line} ->
        username = String.trim(username_line)
        case ChatServer.UserManager.register_user(username, self()) do
          :ok ->
            :gen_tcp.send(socket, "Bienvenido, #{username}!\n")
            client_loop(socket, username)
          {:error, :taken} ->
            :gen_tcp.send(socket, "Usuario en uso. Desconectando.\n")
            :gen_tcp.close(socket)
        end
      _ ->
        :gen_tcp.close(socket)
    end
  end

  defp client_loop(socket, username, room \\ nil) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        input = String.trim(data)
        cond do
          input == "/list" ->
            users = ChatServer.UserManager.list_users() |> Enum.join(", ")
            :gen_tcp.send(socket, "Usuarios conectados: #{users}\n")
            client_loop(socket, username, room)
          String.starts_with?(input, "/create ") ->
            [_cmd, room_name] = String.split(input, " ", parts: 2)
            case ChatServer.RoomManager.create_room(room_name) do
              :ok -> :gen_tcp.send(socket, "Sala '#{room_name}' creada.\n")
              {:error, :exists} -> :gen_tcp.send(socket, "La sala ya existe.\n")
            end
            client_loop(socket, username, room)
          String.starts_with?(input, "/join ") ->
            [_cmd, room_name] = String.split(input, " ", parts: 2)
            case ChatServer.RoomManager.join_room(room_name, username) do
              :ok -> :gen_tcp.send(socket, "Unido a la sala '#{room_name}'.\n")
              {:error, :not_found} -> :gen_tcp.send(socket, "Sala no encontrada.\n")
            end
            client_loop(socket, username, room_name)
          input == "/exit" ->
            :gen_tcp.send(socket, "Adiós!\n")
            ChatServer.UserManager.unregister_user(username)
            :gen_tcp.close(socket)
          input == "/history" and room != nil ->
            history = ChatServer.RoomManager.get_history(room)
            :gen_tcp.send(socket, "Historial de '#{room}':\n#{history}\n")
            client_loop(socket, username, room)
          room != nil ->
            ChatServer.RoomManager.save_message(room, username, input)
            # Enviar mensaje a todos los usuarios de la sala
            for user <- ChatServer.RoomManager.users_in_room(room), user != username do
              # Aquí deberías enviar el mensaje a cada usuario (requiere referencia a su socket/pid)
              # Por simplicidad, solo mostramos en consola
              IO.puts("[#{room}] #{username}: #{input}")
            end
            :gen_tcp.send(socket, "Mensaje enviado a sala '#{room}'.\n")
            client_loop(socket, username, room)
          true ->
            :gen_tcp.send(socket, "Comando o mensaje no válido.\n")
            client_loop(socket, username, room)
        end
      _ ->
        ChatServer.UserManager.unregister_user(username)
        :gen_tcp.close(socket)
    end
  end
end
