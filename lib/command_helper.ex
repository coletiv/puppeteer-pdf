defmodule CommandHelper do
  def get_command(exec_path, parms) do
    command =
      case Application.get_env(:puppeteer_pdf, :is_windows_command) do
        false -> exec_path
        true -> "cmd.exe"
      end
    options =
      case Application.get_env(:puppeteer_pdf, :is_windows_command) do
        false -> parms
        true ->
          {:ok, path} = File.cwd()
          exec_path = "cd " <> path <> " & "<> exec_path
          ["/c",exec_path] ++ parms
      end
      {command, options}
  end
end
