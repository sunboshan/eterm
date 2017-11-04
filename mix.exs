defmodule ETerm.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eterm,
      version: "0.1.0",
      elixir: "~> 1.5",
      compilers: [:elixir_make] ++ Mix.compilers(),
      start_permanent: Mix.env == :prod,
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
      {:elixir_make, "~> 0.4", runtime: false},
    ]
  end
end
