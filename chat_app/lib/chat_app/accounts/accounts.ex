defmodule ChatApp.Accounts do
  import Ecto.Query, warn: false
  alias ChatApp.Repo
  alias ChatApp.Accounts.User

  def get_or_create_user(name) do
    case Repo.get_by(User, name: name) do
      nil -> create_user(%{name: name})
      user -> {:ok, user}
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(user) do
    User.changeset(user, %{})
  end
end
