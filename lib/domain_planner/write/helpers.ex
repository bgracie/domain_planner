defmodule DomainPlanner.Write.Helpers do
  def entity_class_filename(class) do
    class["plural_name"]
      |> String.replace(" ", "_", global: true)
      |> String.downcase
      |> (&(&1 <> ".md")).()
  end

  def formatted_examples(class) do
    if class["examples"] do
      examples = class["examples"]
        |> Enum.map(fn (e) -> "'#{e}'" end)
        |> Enum.join(", ")

      " (e.g. #{examples})"
    else
      ""
    end
  end

  def relevant_freeform_relationships(class, raw) do
    self_freeform_relationships(class, raw) ++
      superclass_freeform_relationships(class, raw)
  end

  def self_freeform_relationships(class, raw) do
    Enum.filter(raw.freeform_relationships, fn (relationship) ->
      String.contains?(relationship, "[#{class["singular_name"]}]") ||
        String.contains?(relationship, "[#{class["plural_name"]}]")
    end)|> Enum.map(fn (relationship) ->
      link_names = Regex.scan(~r/\[([\w\s]+)\]/, relationship)
        |> Enum.map(&Enum.at(&1, 0))
        |> Enum.map(&String.replace(&1, ~r/[\]\[]/, ""))

      Enum.reduce(link_names, relationship, fn (name, acc) ->
        class_ = find(name, raw)

        if !class_ do
          raise ("Could not find class #{name} while "<>
            "constructing freeform relationships.")
        end

        examples =
          if class == class_ || !class_["examples"] do
            ""
          else
            formatted_examples(class_)
          end

        String.replace(
          acc,
          "[#{name}]",
          "[#{name}](#{entity_class_filename(class_)})#{examples}",
          global: true
        )
      end)
    end)
  end

  def superclass_freeform_relationships(class, raw) do
    superclasses(class, raw)
      |> Enum.map(fn (superclass) ->
          relevant_freeform_relationships(
            superclass,
            raw
          )
        end)
      |> List.flatten
  end

  def subclasses(class, raw) do
    Enum.filter(raw.type_relationships, fn (relationship) ->
      find(relationship["superclass"], raw) == class
    end) |> Enum.map(fn (relationship) ->
      find(relationship["subclass"], raw)
    end)
  end

  def superclasses(class, raw) do
    Enum.filter(raw.type_relationships, fn (relationship) ->
      find(relationship["subclass"], raw) == class
    end) |> Enum.map(fn (relationship) ->
      find(relationship["superclass"], raw)
    end)
  end

  defp find(classname, raw) do
    Enum.find(raw.entity_classes, fn (class) ->
      class["singular_name"] == classname || class["plural_name"] == classname
    end)
  end
end