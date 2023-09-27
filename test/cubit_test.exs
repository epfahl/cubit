defmodule CubitTest do
  use ExUnit.Case
  doctest Cubit

  test "greets the world" do
    assert Cubit.hello() == :world
  end
end
