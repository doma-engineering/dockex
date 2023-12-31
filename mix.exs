defmodule Dockex.MixProject do
  use Mix.Project

  def project do
    [
      app: :dockex,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1.0", [runtime: false]},
      {:uptight, github: "doma-engineering/uptight", branch: "main"},
      {:quark_goo, github: "doma-engineering/quark-goo", branch: "main"},
      {:algae_goo, github: "doma-engineering/algae-goo", branch: "main"},
      {:witchcraft_goo, github: "doma-engineering/witchcraft-goo", branch: "main"},
      {:ubuntu, github: "doma-engineering/ubuntu", branch: "main"},
      {:nimble_parsec, "~> 1.3.1"}
    ]
  end
end
