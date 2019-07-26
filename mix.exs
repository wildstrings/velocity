defmodule Velocity.Mixfile do
  use Mix.Project

  def project do
    [
      app: :velocity,
      name: "Velocity",
      description:
        "A simple agent-based library for registering events and reporting event occurrence count",
      package: package(),
      source_url: "https://github.com/wildstrings/velocity",
      version: "0.1.0",
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
    [
      {:ex_doc, "~> 0.21.1", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "velocity",
      files: ~w(),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/wildstrings/velocity"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
