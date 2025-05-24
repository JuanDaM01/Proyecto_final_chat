defmodule ChatServer.Application do
  use Application

  def start(_type, _args) do
    children = [
      ChatServer.UserManager,
      ChatServer.RoomManager,
      ChatServer.TcpServer
    ]

    opts = [strategy: :one_for_one, name: ChatServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
