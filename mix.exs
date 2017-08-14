defmodule Sheriff.Mixfile do
  use Mix.Project

  @version "0.3.0"

  @github "https://github.com/doomspork/sheriff"

  def project do
    [app: :sheriff,
     build_embedded: Mix.env == :prod,
     deps: deps(),
     description: description(),
     docs: docs(),
     elixir: "~> 1.3",
     homepage_url: @github,
     package: package(),
     source_url: @github,
     start_permanent: Mix.env == :prod,
     version: @version]
  end

  def application do
    [applications: [:logger, :plug]]
  end

  defp deps do
    [
      {:plug, ">= 1.2.0"},

      # Development and test dependencies
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    "Build simple and robust authorization systems with Elixir and Plug."
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["Sean Callan", "Bobby Grayson"],
      licenses: ["MIT"],
      links: %{"GitHub": @github}]
  end
end
