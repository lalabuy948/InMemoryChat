defmodule InMemoryChat do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    if connected?(socket), do: MessageStorage.subscribe()
    messages = MessageStorage.get_messages()

    {:ok, assign(socket, messages: messages, message_value: "", current_socket_id: socket.id)}
  end

  def render(assigns) do
    ~H"""
    <head>
      <link href="https://cdn.jsdelivr.net/npm/daisyui@4.12.10/dist/full.min.css" rel="stylesheet" type="text/css" />
      <script src="https://cdn.tailwindcss.com"></script>
    </head>

    <body>

      <div class="h-screen flex items-center justify-center">

      <div class="mockup-phone border-primary">
        <div class="camera"></div>
        <div class="display">
          <div class="artboard artboard-demo phone-1">

                <div class="w-full flex-grow overflow-auto mt-8">
                  <div :for={message <- @messages} className="">
                    <div class={[
                      "chat",
                      if(message.socket_id == @current_socket_id, do: "chat-end", else: "chat-start")]
                    }>
                      <div class="chat-bubble"><%= message.message %></div>
                    </div>
                  </div>
                </div>

              <form phx-submit="new_message" class="form-control m-5 items-center">
                <div class="join">
                  <input class="input input-bordered w-full max-w-xs join-item" type="text" name="text" placeholder="Message..." autofocus>
                  <button type="submit" class="btn btn-active btn-secondary join-item">Send</button>
                </div>
              </form>

          </div>
        </div>
      </div>

    </div>

    </body>
    """
  end

  def handle_event("new_message", %{"text" => message}, socket) do
    MessageStorage.add_message(%{message: message, socket_id: socket.id})

    {:noreply, socket}
  end

  def handle_info({:messages_ware_deleted, messages}, socket) do
    {:noreply, assign(socket, messages: messages)}
  end

  def handle_info({:message_created, message}, socket) do
    {:noreply, assign(socket, messages: socket.assigns.messages ++ [message])}
  end
end
