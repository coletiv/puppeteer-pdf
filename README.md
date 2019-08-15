# PuppeteerPdf

This is a wrapper to NodeJS module [puppeteer-pdf](https://www.npmjs.com/package/puppeteer-pdf). After some attempts to use wkhtmltopdf using [pdf_generator](https://github.com/gutschilla/elixir-pdf-generator), I've decided to use other software to generate PDF and create a wrapper for it.

## Puppeteer PDF vs wkhtmltopdf

I've written a [small blog post](https://coletiv.com/blog/elixir-pdf-generation-puppeteer-wkhtmltopdf/) where I explain my reasons to create this extension. Here is the list of pros and cons compared with `pdf_generator` module.

### Disadvantage

* Bigger PDF file size
* NodeJS 8+ needed
* Chromium Browser needed

### Advantages

* Display independent render (for better testing how template will be).
* Less render issues.

## Installation

Install `puppeteer-pdf` via npm, with the following command:

```
npm i puppeteer-pdf -g
```

In some cases you will need to install this extra dependencies. Here is an example for Debian based distributions.

```
sudo apt-get install libxss1 lsof libasound2 libnss3
```

On your elixir project, you just need to add the following dependency:

```elixir
def deps do
  [
    {:puppeteer_pdf, "~> 1.0.3"}
  ]
end
```

If you have the older `applications` structure inside `mix.exs`, you need to add `:briefly` to it. If you have `extra_applications`, you don't need to do anything.

### Troubleshooting

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
npm i puppeteer -g # This should install chromium
cp -R /usr/local/lib/node_modules/puppeteer/.local-chromium/ /usr/local/lib/node_modules/puppeteer-pdf/node_modules/puppeteer/
```

If you have issues related to this, please comment on [this issue](https://github.com/coletiv/puppeteer-pdf/issues/13).


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

```elixir
# Get template to be rendered. Note that the full filename is "invoice.html.eex", the but ".eex" is not needed here.
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

```elixir
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

### Support special characters

If you see weird characters printed on a language that can have special (like Germam, Chinese, Russian, ...) define the charset as follows:

```html
<head>
  <meta charset="UTF-8">
  ...
```

### Use images or fonts

You can use custom images or text fonts using the following Elixir code that defines the full path to the file. This should be passed in the `assings` variable when rendering the template, as explained above.

```elixir
font1_path = "#{:code.priv_dir(:myapp)}/static/fonts/font1.otf"
```

On template style:

```css
  @font-face {
    font-family: 'GT-Haptik';
    src: url(<%= @font1_path %>) format("opentype");
    font-weight: 100;
  }
```

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

## Continuous Integration / Continuous Deployment

If you use CI

```
before_script:
- nvm install 8
- npm i puppeteer-pdf -g
```

### Docker File

If you are deploying a project with Docker and using this module, this is a working Dockerfile configuration.

You can find instructions on how to deploy this with an `alpine` Docker image in [this issue](https://github.com/coletiv/puppeteer-pdf/issues/24).

This Docker file use a two stage building, with a Debian operative system.

```
#
# Stage 1
#

FROM elixir:1.8.2-slim as builder
ENV MIX_ENV=prod
WORKDIR /myapp

# Umbrella
COPY mix.exs mix.lock ./
COPY config config

RUN mix local.hex --force && \
    mix local.rebar --force

# App
COPY lib lib
# Image / Font files if you need for your PDF document
COPY priv priv
RUN mix do deps.get, deps.compile

WORKDIR /myapp
COPY rel rel

RUN mix release --env=prod --verbose

#
# Stage 2
#

FROM node:10-slim

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst ttf-freefont \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init
# ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-unstable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

ENV MIX_ENV=prod \
    SHELL=/bin/bash

# Install puppeteer so it's available in the container.
RUN npm i puppeteer-pdf \
    # Add user so we don't need --no-sandbox.
    # same layer as npm install to keep re-chowned files from using up several hundred MBs more space
    && groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /node_modules \
    && mkdir /myapp \
    && chown -R pptruser:pptruser /myapp

# Run everything after as non-privileged user.
USER pptruser

WORKDIR /myapp
COPY --from=builder /myapp/_build/prod/rel/myapp/releases/0.1.0/myapp.tar.gz .

RUN tar zxf myapp.tar.gz && rm myapp.tar.gz
CMD ["/myapp/bin/myapp", "foreground"]
```
