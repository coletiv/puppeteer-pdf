defmodule PuppeteerPdf do
  @moduledoc """
  Wrapper library for NodeJS binary puppeteer-pdf.
  """

  @doc false
  @deprecated "Use PuppeteerPdf.Generate.from_string/2"
  @spec generate_with_html(String.t(), String.t(), list()) :: {:ok, String.t()} | {:error, atom()}
  def generate_with_html(html, pdf_output_path, options \\ []) when is_list(options) do
    PuppeteerPdf.Generate.from_string(html, pdf_output_path, options)
  end

  @doc false
  @deprecated "Use PuppeteerPdf.Generate.from_file/2"
  @spec generate(String.t(), String.t(), list()) :: {:ok, String.t()} | {:error, atom()}
  def generate(file_name_path, pdf_output_path, options \\ []) when is_list(options) do
    PuppeteerPdf.Generate.from_file(file_name_path, pdf_output_path, options)
  end

  @doc """
  Get puppeteer-pdf binary version
  """
  @spec get_exec_version() :: String.t()
  def get_exec_version() do
    exec_path =
      case Application.get_env(:puppeteer_pdf, :exec_path) do
        nil -> "puppeteer-pdf"
        value -> value
      end

    case CommandHelper.cmd(exec_path, ["--version"]) do
      {cmd_response, _} ->
        String.replace(cmd_response, "\n", "")
    end
  end

  @doc """
  Verify if the file generated is a valid PDF file
  """
  @spec is_pdf(String.t()) :: boolean
  def is_pdf(file) do
    with {:ok, file_content} <- :file.open(file, [:read, :binary]),
         {:ok, <<37, 80, 68, 70>>} <- :file.read(file_content, 4) do
      true
    else
      _error ->
        false
    end
  end
end
