defmodule PuppeteerPdfTest do
  use ExUnit.Case
  doctest PuppeteerPdf

  test "Generate PDF using HTML" do
    html = "<div>Testing</div>"
    pdf_path = "pdf_test.pdf"

    {:ok, _} = PuppeteerPdf.generate_with_html(html, pdf_path)

    assert File.exists?(pdf_path) == true

    File.rm(pdf_path)
  end
end
