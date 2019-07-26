defmodule Velocity do
  @moduledoc """
  A simple `Elixir.Agent` for registering occurrences of different events and reporting event counts for the given time period.

  Configuration can be passed to `start_link/1` as a keyword list. Supported parameters are:
  - `:ttl` - the duration, in seconds, that events should be stored for. Default is 60;
  - `:default_period` - period to consider by default when `Velocity.of/1` is called. Can be either an integer or a `@time_ranges` key. Default is :minute.

  Anything can be used for event keys. Minimum time granularity is 1 second.

  ## Example

      Velocity.start_link(ttl: 3 * 60, default_period: :minute)

      Velocity.register(:foo)
      Velocity.register(:bar)
      Velocity.register(:foo)

      Velocity.of(:foo)
      #=> {:ok, 2}

      Velocity.of(:foo, :minute)
      #=> {:ok, 2}

      Velocity.of(:bar, :minute)
      #=> {:ok, 1}

      Velocity.of(:baz, :minute)
      #=> {:ok, 0}

      #...after 2 minutes...
      Velocity.of(:foo, :minute)
      #=> {:ok, 0}

      Velocity.of(:foo, 5 * 60)
      #=> {:ok, 2}

      #...after 3 minutes...
      Velocity.of(:foo, 5 * 60)
      #=> {:ok, 0}

  TODO: implement subscribable alerts, e.g. Velocity.alert(self(), :ato, {{:gt, 10}, :minute})
  """

  use Agent

  @time_periods %{
    hour: 60 * 60,
    half_hour: 30 * 60,
    minute: 60,
    second: 1
  }

  @time_period_keys Map.keys(@time_periods)

  def start_link(), do: start_link([])

  def start_link(opts) do
    {ttl, _} = Keyword.pop(opts, :ttl, 5 * 60)
    {default_period, _} = Keyword.pop(opts, :default_period, :minute)

    Agent.start_link(
      fn -> %{config: %{ttl: ttl, default_period: default_period}, events: %{}} end,
      name: __MODULE__
    )
  end

  @doc """
  Registers occurrence of an event. Anything can be used for the event key.
  """
  @spec register(any()) :: :ok
  def register(event) do
    Agent.update(__MODULE__, fn %{config: config, events: events} ->
      %{
        config: config,
        events:
          Map.put(
            events,
            event,
            case events do
              %{^event => points} ->
                put_and_expire(points, now(), config[:ttl])

              _ ->
                [now()]
            end
          )
      }
    end)
  end

  @doc """
  Reports the number of given events registered within the last `period` seconds. Pre-defined constants such as `:minute` or `:hour` may be used.
  """
  @spec of(any(), integer() | atom()) :: {:ok, integer()} | {:error, atom()}
  def of(event, period) when period in @time_period_keys,
    do: of(event, @time_periods[period])

  def of(_, period) when not is_integer(period) do
    {:error, :time_period_must_be_an_integer}
  end

  def of(_, period) when period <= 0,
    do: {:error, :time_period_must_be_positive}

  def of(event, period) do
    Agent.get(__MODULE__, fn %{config: %{ttl: ttl}, events: events} ->
      now = now()

      count =
        case events do
          %{^event => points} ->
            points
            |> Enum.take_while(&(&1 > now - min(period, ttl)))
            |> Enum.count()

          _ ->
            0
        end

      {:ok, count}
    end)
  end

  @spec of(any()) :: {:ok, integer()} | {:error, atom()}
  @doc """
  Reports the number of given events registered within the default time period (see configuration details above).
  """
  def of(event) do
    default_period =
      Agent.get(__MODULE__, fn %{config: %{default_period: default_period}} ->
        default_period
      end)

    of(event, default_period)
  end

  defp now, do: DateTime.utc_now() |> DateTime.to_unix(:second)

  defp put_and_expire(points, moment, ttl),
    do: [moment | Enum.take_while(points, &(&1 > moment - ttl))]
end
