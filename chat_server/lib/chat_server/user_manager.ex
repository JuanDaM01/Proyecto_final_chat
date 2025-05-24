defmodule ChatServer.UserManager do
  use GenServer

  # Estado: %{username => pid}
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register_user(username, pid) do
    GenServer.call(__MODULE__, {:register, username, pid})
  end

  def unregister_user(username) do
    GenServer.cast(__MODULE__, {:unregister, username})
  end

  def list_users do
    GenServer.call(__MODULE__, :list)
  end

  # Callbacks
  def init(state), do: {:ok, state}

  def handle_call({:register, username, pid}, _from, state) do
    if Map.has_key?(state, username) do
      {:reply, {:error, :taken}, state}
    else
      {:reply, :ok, Map.put(state, username, pid)}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end

  def handle_cast({:unregister, username}, state) do
    {:noreply, Map.delete(state, username)}
  end
end
