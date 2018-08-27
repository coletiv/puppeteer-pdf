defmodule PuppeteerPdfTest do
  use ExUnit.Case
  doctest PuppeteerPdf

  describe "valid generate output file" do
    test "Generate PDF using HTML" do
      html_value = "<div>Testing 1</div>"
      pdf_path = "pdf_test.pdf"

      {:ok, _} = PuppeteerPdf.Generate.from_string(html_value, pdf_path)

      assert File.exists?(pdf_path) == true
      assert PuppeteerPdf.is_pdf(pdf_path)

      File.rm(pdf_path)
    end

    test "Generate PDF using HTML file" do
      html_value = "<div>Testing 2</div>"
      html_path = "file.html"
      pdf_path = "pdf_test.pdf"

      {:ok, file} = File.open(html_path, [:write, :utf8])
      IO.write(file, html_value)
      File.close(file)
      html_full_path = Path.absname(html_path)

      {:ok, _} = PuppeteerPdf.Generate.from_file(html_full_path, pdf_path)

      assert File.exists?(pdf_path) == true
      assert PuppeteerPdf.is_pdf(pdf_path)

      File.rm(pdf_path)
      File.rm(html_path)
    end
  end

  describe "invalid parameters provided" do
    test "Handle invalid scale value" do
      html_value = "<div>Testing 3</div>"
      html_path = "file.html"
      pdf_path = "pdf_test.pdf"

      {:ok, file} = File.open(html_path, [:write, :utf8])
      IO.write(file, html_value)
      File.close(file)
      html_full_path = Path.absname(html_path)

      {:error, :invalid_scale} =
        PuppeteerPdf.Generate.from_file(html_full_path, pdf_path, scale: 3)

      assert File.exists?(pdf_path) == false
      File.rm(html_path)
    end

    test "Handle invalid PDF file path" do
      html_value = "<div>Testing 3</div>"
      html_path = "file.html"
      pdf_path = "/file.pdf"

      {:ok, file} = File.open(html_path, [:write, :utf8])
      IO.write(file, html_value)
      File.close(file)
      html_full_path = Path.absname(html_path)

      exit_value = catch_exit(PuppeteerPdf.Generate.from_file(html_full_path, pdf_path))

      timeout =
        case(exit_value) do
          {:timeout, _} ->
            true

          _ ->
            false
        end

      File.rm(html_path)
      assert File.exists?(pdf_path) == false
      assert timeout
    end
  end

  test "Check puppeteer-pdf version" do
    PuppeteerPdf.get_exec_version()
  end
end
