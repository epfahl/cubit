defmodule Cubit.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :cubit,
      version: @version,
      elixir: "~> 1.15",
      description: description(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/epfahl/cubit",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:decimal, "~> 2.1"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:ratio, "~> 4.0"}
    ]
  end

  defp description() do
    "Elixir library for working with dimensions, units, and measures."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Eric Pfahl"],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/epfahl/cubit"
      }
    ]
  end

  defp docs() do
    [
      main: "Cubit",
      extras: ["README.md"]
    ]
  end
end
