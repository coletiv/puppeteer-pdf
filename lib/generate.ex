defmodule PuppeteerPdf.Generate do
  @moduledoc """
  Generate a PDF file from multiple available sources.
  """

  @doc """
  Generate PDF file given an HTML string input

  ## Options
  - `header_template` - HTML template for the print header.
  - `footer_template` - HTML template for the print footer.
  - `display_header_footer` - Display header and footer.
  - `format` - Page format. Possible values: Letter, Legal, Tabloid, Ledger, A0, A1, A2, A3, A4, A5, A6
  - `margin_left` - Integer value or string with one of the supported units (px, in, mm, cm)
  - `margin_right` - Integer value or string with one of the supported units (px, in, mm, cm)
  - `margin_top` - Integer value or string with one of the supported units (px, in, mm, cm)
  - `margin_bottom` - Integer value or string with one of the supported units (px, in, mm, cm)
  - `scale` - Scale of the webpage rendering. (default: 1). Accept values between 0.1 and 2.
  - `width` - Paper width, accepts values labeled with units.
  - `height` - Paper height, accepts values labeled with units.
  - `debug` - Output Puppeteer PDF options
  - `landscape` - Paper orientation.
  - `print_background` - Print background graphics.
  - `timeout` - Integer value (ms), configures the timeout of the PDF creation (defaults to 5000)
  """
  @spec from_string(String.t(), String.t(), list()) :: {:ok, String.t()} | {:error, atom()}
  def from_string(html_code, pdf_output_path, options \\ []) do
    # Random gen filename
    {:ok, path} = Briefly.create(extname: ".html")

    case File.open(path, [:write, :utf8]) do
      {:ok, file} ->
        IO.write(file, html_code)
        File.close(file)

        Path.absname(path)
        |> from_file(pdf_output_path, options)

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Generate PDF file with an HTML file path given as input.

  ## Options
  - `header_template` - HTML template for the print header.
  - `footer_template` - HTML template for the print footer.
  - `display_header_footer` - Display header and footer.
  - `format` - Page format. Possible values: Letter, Legal, Tabloid, Ledger, A0, A1, A2, A3, A4, A5, A6
  - `margin_left` - Integer value (px)
  - `margin_right` - Integer value (px)
  - `margin_top` - Integer value (px)
  - `margin_bottom` - Integer value (px)
  - `scale` - Scale of the webpage rendering. (default: 1). Accept values between 0.1 and 2.
  - `width` - Paper width, accepts values labeled with units.
  - `height` - Paper height, accepts values labeled with units.
  - `debug` - Output Puppeteer PDF options
  - `landscape` - Paper orientation.
  - `print_background` - Print background graphics.
  - `timeout` - Integer value (ms), configures the timeout of the PDF creation (defaults to 5000)
  - `wait_until` - :load, :domcontentloaded, :networkidle0, :networkidle2
  """
  @spec from_file(String.t(), String.t(), list()) :: {:ok, String.t()} | {:error, atom()}
  def from_file(html_file_path, pdf_output_path, options \\ []) do
    case File.exists?(html_file_path) do
      true ->
        exec_path =
          case Application.get_env(:puppeteer_pdf, :exec_path) do
            nil -> "puppeteer-pdf"
            value -> value
          end

        params =
          Enum.reduce(options, [html_file_path, "--path", pdf_output_path], fn {key, value},
                                                                               result ->
            value =
              case key do
                :header_template ->
                  ["--headerTemplate=#{value}"]

                :footer_template ->
                  ["--footerTemplate=#{value}"]

                :display_header_footer ->
                  ["--displayHeaderFooter"]

                :format ->
                  if(
                    Enum.member?(
                      [
                        "letter",
                        "legal",
                        "tabloid",
                        "ledger",
                        "a0",
                        "a1",
                        "a2",
                        "a3",
                        "a4",
                        "a5",
                        "a6"
                      ],
                      to_string(value) |> String.downcase()
                    )
                  ) do
                    ["--format", to_string(value)]
                  else
                    {:error, :invalid_format}
                  end

                :margin_left ->
                  cast_value("--marginLeft", value)

                :margin_right ->
                  cast_value("--marginRight", value)

                :margin_top ->
                  cast_value("--marginTop", value)

                :margin_bottom ->
                  cast_value("--marginBottom", value)

                :scale ->
                  with {value, ""} <- Float.parse(to_string(value)),
                       true <- value >= 0.1 && value <= 2.0 do
                    ["--scale", to_string(value)]
                  else
                    _ -> {:error, :invalid_scale}
                  end

                :width ->
                  cast_value("--width", value)

                :height ->
                  cast_value("--height", value)

                :wait_until ->
                  if Enum.member?([:load, :domcontentloaded, :networkidle0, :networkidle2], value) do
                    ["--waitUntil", Atom.to_string(value)]
                  else
                    {:error, :invalid_wait_until_value}
                  end

                :debug ->
                  ["--debug"]

                :landscape ->
                  ["--landscape"]

                :print_background ->
                  ["--printBackground"]

                :timeout ->
                  # timeout is not an argument for puppeteer-pdf
                  :ignore
              end

            case result do
              {:error, message} ->
                {:error, message}

              _ ->
                case value do
                  {:error, message} ->
                    {:error, message}

                  :ignore ->
                    result

                  _ ->
                    result ++ value
                end
            end
          end)

        case params do
          {:error, message} ->
            {:error, message}

          _ ->
            # In some cases when invalid values are provided the command executing
            # can hang process. This will assure that it can exit.
            task =
              Task.async(fn ->
                try do
                  case CommandHelper.cmd(exec_path, params) do
                    {_, 127} ->
                      {:error, :invalid_exec_path}

                    {cmd_response, _} ->
                      {:ok, cmd_response}

                    error_message ->
                      {:error, error_message}
                  end
                rescue
                  e in ErlangError ->
                    %ErlangError{original: error} = e

                    case error do
                      :enoent ->
                        # This will happen when the file in exec_path doesn't exists
                        {:error, :invalid_exec_path}
                    end
                end
              end)

            Task.await(task, options[:timeout] || 5000)
        end

      false ->
        {:error, :input_file_not_found}
    end
  end

  @spec cast_value(String.t(), Integer.t()) ::
          list() | {:error, :must_be_integer_or_units}

  defp cast_value(field, value) when is_integer(value) do
    [field, "#{value}px"]
  end

  defp cast_value(field, value) do
    case String.match?(value, ~r/\A[0-9]+(px|in|cm|mm)\Z/) do
      true ->
        [field, value]

      false ->
        {:error, :must_be_integer_or_units}
    end
  end
end
