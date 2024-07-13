defmodule InMemoryChatTest do
  use ExUnit.Case
  doctest InMemoryChat

  test "greets the world" do
    assert InMemoryChat.hello() == :world
  end
end
