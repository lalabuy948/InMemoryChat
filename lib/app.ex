defmodule App do
  use Application

  def start(_type, _args) do
    children = [
      Supervisor.child_spec({Phoenix.PubSub, name: :demo_pub_sub}, id: :demo_pub_sub),
      MessageStorage
    ]

    PhoenixPlayground.start(live: InMemoryChat, child_specs: children)
  end
end
