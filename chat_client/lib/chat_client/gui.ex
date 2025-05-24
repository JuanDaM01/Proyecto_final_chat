defmodule ChatClient.Gui do
  use Scenic.Scene

  alias Scenic.Graph
  import Scenic.Primitives

  @server_ip {127, 0, 0, 1}
  @server_port 4040

  @initial_graph Graph.build()
    |> text("Chat Distribuido", translate: {20, 40}, font_size: 28)
    |> text("Sala: Ninguna", id: :room_label, translate: {20, 65}, font_size: 18)
    |> text("Mensajes:", translate: {20, 90})
    |> rect({400, 200}, id: :msg_box, translate: {20, 110}, fill: :white)
    |> text("Usuarios:", translate: {440, 90})
    |> rect({120, 200}, id: :users_box, translate: {440, 110}, fill: :white)
    |> text_field("", id: :input, translate: {20, 340}, width: 400)

  def init(_, _opts) do
    # Conexión TCP al servidor
    {:ok, socket} = :gen_tcp.connect(@server_ip, @server_port, [:binary, packet: :line, active: true])
    # Espera el prompt de usuario del servidor
    receive do
      {:tcp, ^socket, _prompt} ->
        # Enviar nombre de usuario (por simplicidad, "cliente1")
        :gen_tcp.send(socket, "cliente1\n")
    after
      1000 -> :ok
    end
    state = %{
      graph: @initial_graph,
      messages: [],
      users: [],
      input: "",
      socket: socket,
      room: nil
    }
    {:ok, state, push: @initial_graph}
  end

  def handle_info({:tcp, _socket, data}, state) do
    msg = String.trim(data)
    cond do
      String.starts_with?(msg, "Usuarios conectados:") ->
        users = msg |> String.replace("Usuarios conectados:", "") |> String.split(",", trim: true)
        graph = update_users(state.graph, users)
        {:noreply, %{state | users: users, graph: graph}, push: graph}
      String.starts_with?(msg, "Unido a la sala") ->
        [_, sala] = Regex.run(~r/Unido a la sala '(.+)'./, msg)
        graph = update_room(state.graph, sala)
        messages = state.messages ++ [msg]
        {:noreply, %{state | room: sala, messages: messages, graph: graph}, push: graph}
      String.starts_with?(msg, "Sala '") and String.contains?(msg, "creada") ->
        messages = state.messages ++ [msg]
        {:noreply, %{state | messages: messages}, push: update_messages(state.graph, messages)}
      true ->
        messages = state.messages ++ [msg]
        {:noreply, %{state | messages: messages}, push: update_messages(state.graph, messages)}
    end
  end

  def handle_info({:tcp_closed, _socket}, state) do
    messages = state.messages ++ ["[Desconectado del servidor]"]
    graph = update_messages(state.graph, messages)
    {:noreply, %{state | messages: messages, graph: graph}, push: graph}
  end

  # Manejar eventos de entrada de texto
  def handle_input({:text_input, {:input, text}}, _context, state) do
    {:noreply, %{state | input: text}}
  end

  # Manejar envío de mensaje/comando (por ejemplo, al presionar Enter)
  def handle_input({:key, {:key_enter, :press, _}}, _context, %{input: input, socket: socket} = state) do
    :gen_tcp.send(socket, input <> "\n")
    {:noreply, %{state | input: ""}}
  end

  def handle_input(_event, _context, state), do: {:noreply, state}

  defp update_messages(graph, messages) do
    text = Enum.join(Enum.take(-messages, 15), "\n")
    # Aquí podrías actualizar el área de mensajes usando Scenic primitives
    # Por simplicidad, solo se retorna el mismo graph
    graph
  end

  defp update_users(graph, users) do
    # Aquí podrías actualizar el área de usuarios usando Scenic primitives
    # Por simplicidad, solo se retorna el mismo graph
    graph
  end

  defp update_room(graph, room) do
    Graph.modify(graph, :room_label, &text(&1, "Sala: #{room}", translate: {20, 65}, font_size: 18))
  end
end
