defmodule ETermTest do
  use ExUnit.Case
  doctest ETerm

  test "greets the world" do
    assert ETerm.hello() == :world
  end
end
