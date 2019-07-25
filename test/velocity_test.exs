defmodule VelocityTest do
  use ExUnit.Case

  test "register() and of() work properly" do
    Velocity.start_link(ttl: 2, default_period: 5)

    Velocity.register(:foo)
    Velocity.register(:foo)

    assert Velocity.of(:foo) == 2
    assert Velocity.of(:bar) == 0

    :timer.sleep(1000)

    Velocity.register(:bar)

    assert Velocity.of(:foo) == 2
    assert Velocity.of(:foo, 1) == 0
    assert Velocity.of(:bar) == 1

    :timer.sleep(1000)

    assert Velocity.of(:foo) == 0
    assert Velocity.of(:bar) == 1
  end
end
