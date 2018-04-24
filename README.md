# PuppeteerPdf

This is a wrapper to NodeJS module [puppeteer_pdf](https://www.npmjs.com/package/puppeteer-pdf). After some attempts to use wkhtmltopdf using (pdf_generator)[https://github.com/gutschilla/elixir-pdf-generator], I've decided to use other software to generate PDF and create a wrapper for it.

## Puppeteer PDF vs wkhtmltopdf

### Disadvantage

* Bigger PDF file size.
* NodeJS 8+ needed

### Advantages

* Display independent render (for better testing how template will be).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `puppeteer_pdf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:puppeteer_pdf, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/puppeteer_pdf](https://hexdocs.pm/puppeteer_pdf).
