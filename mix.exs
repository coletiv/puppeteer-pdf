defmodule PuppeteerPdf.MixProject do
  use Mix.Project

  def project do
    [
      app: :puppeteer_pdf,
      version: "1.0.4",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      package: [
        maintainers: ["David Magalhães"],
        licenses: ["MIT"],
        links: %{github: "https://github.com/coletiv/puppeteer-pdf"}
      ],
      description: """
      Wrapper for Puppeteer-pdf, a node module that use Puppeteer to convert
      HTML pages to PDF.
      """,

      # Docs
      name: "Puppeteer PDF",
      source_url: "https://github.com/coletiv/puppeteer-pdf",
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def aliases do
    [compile: ["compile --warnings-as-errors"]]
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
      {:ex_doc, "~> 0.18", only: :dev},
      {:briefly, "~> 0.3"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end
end
