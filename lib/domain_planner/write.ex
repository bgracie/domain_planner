defmodule DomainPlanner.Write do
  alias DomainPlanner.Write.Helpers

  def _(compiled_dir, parsed) do
    index(compiled_dir, parsed)
    DomainPlanner.Write.ClassPages._(compiled_dir, parsed)
  end

  defp index(compiled_path, raw) do
    File.open("#{compiled_path}/entity_class_index.md", [:write], fn (file) ->
      IO.write(file, "# Entity Classes\n")
      IO.write(file, "\n")


      Enum.each(raw.entity_classes, fn (class) ->
        entity_class_filename_ = Helpers.entity_class_filename(class)

        IO.write(
          file,
          "  * [#{class["plural_name"]}](#{entity_class_filename_})  \n"
        )
      end)
    end)
  end

end