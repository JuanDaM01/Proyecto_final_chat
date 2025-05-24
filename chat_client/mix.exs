defmodule ChatClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: [
        {:scenic, "~> 0.11"},
        {:scenic_driver_glfw, "~> 0.11"}
      ]
    ]
  end

  def application do
    [
      mod: {ChatClient.Application, []},
      extra_applications: [:logger]
    ]
  end
end
