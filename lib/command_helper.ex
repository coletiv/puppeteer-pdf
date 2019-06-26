defmodule CommandHelper do
  def get_command(exec_path, parms) do
    command =
      case :os.type() do
        {:win32, _value} -> "cmd.exe"
        _ -> exec_path
      end
    options =
      case :os.type() do
        {:win32, _value} ->
          {:ok, path} = File.cwd()
          exec_path = "cd " <> path <> " & "<> exec_path
          ["/c",exec_path] ++ parms
          _ -> parms
      end
      {command, options}
  end
end
