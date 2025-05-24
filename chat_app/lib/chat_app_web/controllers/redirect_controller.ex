defmodule ChatAppWeb.RedirectController do
  use ChatAppWeb, :controller

  def to_lobby(conn, _params) do
    redirect(conn, to: "/chat/lobby")
  end
end
