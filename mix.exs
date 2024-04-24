defmodule PortServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :port_server,
      version: "0.1.0",
      elixir: "~> 1.16",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "PortServer",
      source_url: "https://github.com/yuanlin2008/port_server"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def description do
    "PortServer is a GenServer implementation of a external local server(NodeJS)."
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["yuanlin2008"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/yuanlin2008/port_server"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
