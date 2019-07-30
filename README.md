# Velocity

A simple `Agent`-based Elixir library for registering events and reporting event occurrence count for the given time period.

## Installation

Add Velocity to `mix.exs`:

```elixir
defp deps do
  [{:velocity, ">= 0.1.0"}]
end
```

Run `mix deps.get` to fetch the package.

## Usage

Start Velocity:

```elixir
Velocity.start_link(ttl: 5 * 60, default_period: :minute)
```

Parameters can be omitted. Default values are:
```elixir
[
    ttl: 300,
    default_period: 60 
]
```
Note that all parameters are in seconds. For `default_period` values and in calls to `Velocity.of()`, the `:second`, `:minute`, `:half_hour` and `:hour` shorthands can also be used 
    
Register some events:

```elixir
Velocity.register(:foo)
Velocity.register(:bar)
Velocity.register(:foo)
Velocity.register({:some, "event", [%{metadata: 42}]})
```

Get event count for the default period in the past:
```elixir
Velocity.of(:foo)
#=> {:ok, 2}
```

Get event count for the last 60 seconds:
```elixir
Velocity.of(:bar, 60)
#=> {:ok, 1}
```

The same using a shorthand:
```elixir
Velocity.of(:bar, :minute)
#=> {:ok, 1}
```

### TODO

Implement subscribable alerts when an event's frequency hits a specified threshold.

### License

MIT License
