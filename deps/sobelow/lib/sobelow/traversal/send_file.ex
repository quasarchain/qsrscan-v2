defmodule Sobelow.Traversal.SendFile do
  use Sobelow.Finding
  @finding_type "Traversal.SendFile: Directory Traversal in `send_file`"

  def run(fun, meta_file) do
    confidence = if !meta_file.is_controller?, do: :low

    Finding.init(@finding_type, meta_file.filename, confidence)
    |> Finding.multi_from_def(fun, parse_def(fun))
    |> Enum.each(&Print.add_finding(&1))
  end

  ## send_file(conn, status, file, offset \\ 0, length \\ :all)
  defp parse_def(fun) do
    Parse.get_fun_vars_and_meta(fun, 2, :send_file, :Conn)
  end

  def details() do
    Sobelow.Traversal.details()
  end
end
