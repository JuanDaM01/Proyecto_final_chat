defmodule ChatClient.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Scenic, viewports: [
        main: %{
          size: {600, 400},
          default_scene: {ChatClient.Gui, nil},
          drivers: [
            %{
              module: Scenic.Driver.Glfw,
              name: :glfw,
              opts: [resizeable: true, title: "Chat Distribuido"]
            }
          ]
        }
      ]}
    ]

    opts = [strategy: :one_for_one, name: ChatClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
