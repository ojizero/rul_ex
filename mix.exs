defmodule RulEx.MixProject do
  use Mix.Project

  @scm_url "https://github.com/ojizero/rulex"

  def project do
    [
      app: :rul_ex,
      version: "1.0.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      name: "RulEx",
      source_url: @scm_url,
      homepage_url: @scm_url,
      docs: [
        main: "README",
        extras: ["README.md"]
      ],
      description: "A simple to use, simple to extend rules engine, written in Elixir.",
      package: package()
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

  defp package do
    [
      maintainers: ["Ameer A."],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @scm_url
      }
    ]
  end
end
