defmodule Diplomat.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [app: :diplomat,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp deps do
    [
      {:plug, "~> 1.2.2"},
      {:credo, "~> 0.5", only: [:dev, :test]},
    ]
  end
end
