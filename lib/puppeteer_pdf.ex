defmodule PuppeteerPdf do
  @moduledoc """
  Wrapper for Puppeteer-Pdf.
  """

  @doc """
  Generate PDF file using HTML code
  """
  def generate_with_html(html, pdf_output_path, options \\ []) do
    # Random gen filename
    pdf_gen_html_filename = "pdfgen_" <> random_string_alphanumeric(10) <> ".html"

    case File.open pdf_gen_html_filename, [:write, :utf8] do
        {:ok, file} ->
          IO.write(file, html)
          File.close file

          html_path = Path.absname(pdf_gen_html_filename)
          result = generate(html_path, pdf_output_path, options)
          File.rm(pdf_gen_html_filename)

          result

        {:error, error} -> {:error, error}
    end
  end

  def generate(html_input_path, pdf_output_path, options \\ []) do
     exec_path = case Application.get_env(:puppeteer_pdf, :exec_path) do
       nil -> "puppeteer-pdf"
       value -> value
     end

     params = Enum.reduce(options, [html_input_path, "--path", pdf_output_path], fn ({key, value}), result ->
       result ++ case key do
         :header_template -> ["--headerTemplate=#{value}"]
         :footer_template -> ["--footerTemplate=#{value}"]
         :display_header_footer -> ["--displayHeaderFooter", to_string(value)]
         :format -> ["--format", to_string(value)]
         :print_background -> ["--printBackground", to_string(value)]
         :margin_left -> ["--marginLeft", to_string(value)]
         :margin_right -> ["--marginRight", to_string(value)]
         :margin_top -> ["--marginTop", to_string(value)]
         :margin_bottom -> ["--marginBottom", to_string(value)]
         :debug -> ["--debug"]
       end
    end)

    case System.cmd(exec_path, params) do
      {cmd_response, _} ->
        {:ok, cmd_response}

      error_message ->
        {:error, error_message}
    end
  end

  @alphabet Enum.concat([?0..?9, ?A..?Z, ?a..?z])
  defp random_string_alphanumeric(count) do
    # Technically not needed, but just to illustrate we're
    # relying on the PRNG for this in random/1
    :rand.seed(:exsplus, :os.timestamp())
    Stream.repeatedly(&random_char_from_alphabet/0)
    |> Enum.take(count)
    |> List.to_string()
  end

  defp random_char_from_alphabet() do
    Enum.random(@alphabet)
  end
end
