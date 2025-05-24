defmodule ChatAppWeb.LoginLive do
  use ChatAppWeb, :live_view
  alias ChatApp.Accounts
  alias ChatApp.Accounts.User

  def mount(_params, _session, socket) do
    changeset = User.changeset(%User{}, %{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => %{"name" => name}}, socket) do
    case Accounts.get_or_create_user(name) do
      {:ok, user} ->
        {:noreply,
        push_navigate(socket,
          to: ~p"/chat/lobby",
          session: %{"user_id" => user.id}
        )}

      {:error, _reason} ->
        {:noreply,
        put_flash(socket, :error, "No se pudo crear el usuario")}
    end
  end
end
