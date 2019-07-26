defmodule VelocityTest do
  use ExUnit.Case

  setup do
    Velocity.start_link(ttl: 2, default_period: 5)
    :ok
  end

  test "register() and of() work properly" do
    Velocity.register(:foo)
    Velocity.register(:foo)

    assert Velocity.of(:foo) == {:ok, 2}
    assert Velocity.of(:bar) == {:ok, 0}
    assert Velocity.of(:baz) == {:ok, 0}

    :timer.sleep(1000)

    Velocity.register(:bar)

    assert Velocity.of(:foo) == {:ok, 2}
    assert Velocity.of(:foo, 1) == {:ok, 0}
    assert Velocity.of(:bar) == {:ok, 1}

    :timer.sleep(1000)

    assert Velocity.of(:foo) == {:ok, 0}
    assert Velocity.of(:bar) == {:ok, 1}
  end

  test "invalid of() time period parameter are properly handled" do
    assert Velocity.of(:foo, []) == {:error, :time_period_must_be_an_integer}
    assert Velocity.of(:foo, 0) == {:error, :time_period_must_be_positive}
    assert Velocity.of(:foo, -1) == {:error, :time_period_must_be_positive}
  end
end
