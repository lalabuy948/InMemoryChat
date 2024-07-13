defmodule MessageStorage do
  use GenServer

  @cleanup_interval 1_000
  @message_ttl 10

  defstruct [:message, :created_at, :current_socket_id]

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    schedule_cleanup()
    {:ok, []}
  end

  def add_message(%{message: message, socket_id: current_socket_id}) do
    message = %{
      message: message,
      socket_id: current_socket_id,
      created_at: now()
    }

    GenServer.cast(__MODULE__, {:add_message, message})

    broadcast({:ok, message}, :message_created)
  end

  def get_messages() do
    GenServer.call(__MODULE__, :get_messages)
  end

  def handle_cast({:add_message, message}, state) do
    {:noreply, [message | state]}
  end

  def handle_call(:get_messages, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:cleanup, state) do
    new_state = clean_oldest_message(state)
    schedule_cleanup()

    Phoenix.PubSub.broadcast(:demo_pub_sub, "message_topic", {:messages_ware_deleted, new_state})

    {:noreply, new_state}
  end

  def subscribe, do: Phoenix.PubSub.subscribe(:demo_pub_sub, "message_topic")

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(:demo_pub_sub, "message_topic", {event, message})
    {:ok, message}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @cleanup_interval)
  end

  defp clean_oldest_message([]), do: []

  defp clean_oldest_message(state) do
    state
    |> Enum.filter(fn %{created_at: created_at} -> now() - created_at <= @message_ttl end)
    |> Enum.sort_by(& &1.created_at, :asc)
  end

  defp now(diff \\ 0) do
    :os.system_time(:seconds) - diff
  end
end
