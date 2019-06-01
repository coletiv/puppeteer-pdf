# PuppeteerPdf

This is a wrapper to NodeJS module [puppeteer_pdf](https://www.npmjs.com/package/puppeteer-pdf). After some attempts to use wkhtmltopdf using [pdf_generator](https://github.com/gutschilla/elixir-pdf-generator), I've decided to use other software to generate PDF and create a wrapper for it.

## Puppeteer PDF vs wkhtmltopdf

### Disadvantage

* Bigger PDF file size.
* NodeJS 8+ needed

### Advantages

* Display independent render (for better testing how template will be).

## Installation

Install `puppeteer-pdf` via npm, with the following command:

```
npm i puppeteer-pdf -g
```

If for some reason it doesn't download automatically chromium, it will give you the following error:

```
(node:14878) UnhandledPromiseRejectionWarning: Error: Chromium revision is not downloaded. Run "npm install" or "yarn install"
at Launcher.launch (/usr/local/lib/node_modules/puppeteer-pdf/node_modules/puppeteer/lib/Launcher.js:119:15)
at <anonymous>
(node:14878) UnhandledPromiseRejectionWarning: Unhandled promise rejection. This error originated either by throwing inside of an async function without a catch block, or by rejecting a promise which was not handled with .catch(). (rejection id: 1)
(node:14878) [DEP0018] DeprecationWarning: Unhandled promise rejections are deprecated. In the future, promise rejections that are not handled will terminate the Node.js process with a non-zero exit code.
```

To solve this, you execute the following commands to copy chromium from the `puppeteer` folder, to the `puppeteer` inside the `puppeteer-pdf`.

On OSX and Linux systems should be the following commands:

```
npm -i puppeteer -g # This should install chromium
cp -R /usr/local/lib/node_modules/puppeteer/.local-chromium/ /usr/local/lib/node_modules/puppeteer-pdf/node_modules/puppeteer/
```

If you have issues related to this, please comment on [this issue](https://github.com/coletiv/puppeteer-pdf/issues/13).

On your elixir project, you just need to add the following dependency:

```elixir
def deps do
  [
    {:puppeteer_pdf, "~> 1.0.1"}
  ]
end
```

If you have the older `applications` structure inside `mix.exs`, you need to add `:briefly` to it. If you have `extra_applications`, you don't need to do anything.

## How to use

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
  debug: true,
  timeout: 10000 # value passed directly to Task.await/2. (Defaults to 5000)
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

case PuppeteerPdf.Generate.from_string(html, pdf_path, options) do
  {:ok, _} -> ...
  {:error, message} -> ...
end
```

Or just with HTML file:

```
html_path = Path.absname("random.html")
case PuppeteerPdf.Generate.from_file(html_path, pdf_path, options) do
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

Or you can use system environment variable:

```
export PUPPETEER_PDF_PATH=/usr/local/bin/puppeteer-pdf
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
