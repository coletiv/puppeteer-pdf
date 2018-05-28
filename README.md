# PuppeteerPdf

This is a wrapper to NodeJS module [puppeteer_pdf](https://www.npmjs.com/package/puppeteer-pdf). After some attempts to use wkhtmltopdf using [pdf_generator](https://github.com/gutschilla/elixir-pdf-generator), I've decided to use other software to generate PDF and create a wrapper for it.

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
    {:puppeteer_pdf, "~> 0.1.1"}
  ]
end
```

## Use

### Initial
These are the options available right now:

```elixir
options = [
  margin_left: 40,
  margin_right: 40,
  margin_top: 40,
  margin_bottom: 150,
  format: "A4",
  print_background: true,
  header_template: header_html, # Support both file and html
  footer_template: footer_html,
  display_header_footer: true,
  debug: true
]
```

And to generate the PDF you can use the following code using Phoenix Template:

```
# Get template rendered previously
html = Phoenix.View.render_to_string(
  MyApp.View,
  "pdf/invoice.html",
  assigns
)

# Get full path to generated pdf file
pdf_path = Path.absname("invoice.pdf")

case PuppeteerPdf.generate_with_html(html, pdf_path, options) do
  {:ok, _} -> ...
  {:error, message} -> ...
end
```

Or just with HTML file:

```
html_path = Path.absname("random.html")
case PuppeteerPdf.generate_with_html(html_path, pdf_path, options) do
  {:ok, _} -> ...
  {:error, message} -> ...
end
```

### Using header and footer templates

You can defined an HTML header and footer, using the `header_template` and `footer_template` options.
To use a file, use the following format: `file:///home/user/file.html`.

Don't forget to also include `display_header_footer` to `true`.

### Configure execution path

In order to configure this setting:

```elixir
config :puppeteer_pdf, exec_path: "/usr/local/bin/puppeteer-pdf"
```

For development purposes when working on this project, you can set the `PUPPETEER_PDF_PATH`
environment variable to point to the `puppeteer-pdf` executable. **Do not attempt to use this env
var to set the path in production. Instead, use the application configuration, above.**

### Continuous Integration

If you use CI

```
before_script:
- nvm install 8
- npm i puppeteer-pdf -g
```

### Configuring the `puppeteer-pdf` path


```elixir

```
