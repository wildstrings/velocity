defmodule Velocity.Mixfile do
  use Mix.Project

  @vsn "0.0.1"

  def project do
    [
      app: :velocity,
      name: "Velocity",
      description: "Event frequency tracker",
      source_url: "https://github.com/wildstrings/velocity",
      version: @vsn,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
