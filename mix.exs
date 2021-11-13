defmodule Rulex.MixProject do
  use Mix.Project

  def project do
    [
      app: :rulex,
      version: "1.0.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "Rulex",
      source_url: "https://github.com/ojizero/rulex",
      homepage_url: "https://github.com/ojizero/rulex",
      docs: [
        main: "README",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2", optional: true},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/fixtures"]
  defp elixirc_paths(_else), do: ["lib"]
end
