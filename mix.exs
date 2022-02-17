defmodule MotleyHue.MixProject do
  use Mix.Project

  def project do
    [
      app: :motley_hue,
      name: "Mötley Hüe",
      description: "An Elixir utility for calculating color combinations.",
      version: "0.3.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      package: package(),
      source_url: "https://github.com/Cameron-Kurth/motley_hue",
      docs: [
        extras: ["README.md"],
        main: "readme"
      ]
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
      {:chameleon, "~> 2.5.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:wx, :ex_unit]
    ]
  end

  defp package do
    [
      maintainers: ["Cameron Kurth"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Cameron-Kurth/motley_hue"}
    ]
  end
end
