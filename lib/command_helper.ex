defmodule CommandHelper do
  def cmd(exec_path, params) do
    {command, options} = get_command(exec_path, params)
    System.cmd(command, options)
  end

  defp get_command(exec_path, params) do
    command =
      case :os.type() do
        {:win32, _value} -> "cmd.exe"
        _ -> exec_path
      end

    options =
      case :os.type() do
        {:win32, _value} ->
          # The reason for changing to the current directory is that when a new
          # windows command prompt is initiated it goes to c:\ or root directory.
          # If a user doesn't specify a full path name for the pdf, as is in the
          # test, the pdf would be saved to the c:.
          #
          # By changing to the current working directory we avoid this scenario.
          # In a unix scenario when running the command you're prompt is already
          # in a specific directory, so this situation is avoided.
          {:ok, path} = File.cwd()
          exec_path = "cd " <> path <> " & " <> exec_path
          ["/c", exec_path] ++ params

        _ ->
          params
      end

    {command, options}
  end
end
