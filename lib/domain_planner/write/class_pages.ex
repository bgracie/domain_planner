defmodule DomainPlanner.Write.ClassPages do
  alias DomainPlanner.Write.Helpers

  def _(compiled_dir, raw) do
    raw.entity_classes
    |> Stream.with_index
    |> Enum.each(fn ({elem, index}) ->
      File.open(
        "#{compiled_dir}/#{Helpers.entity_class_filename(elem)}",
        [:write],
        &class_page(elem, index, raw, &1)
      )
    end)
  end

  defp class_page(class, index, raw, file) do
    navigation(file, raw, index)

    IO.write(file, "___\n")

    plural_name(class, file)

    definition(class, file)

    attributes(class, file)

    examples(class, file)

    subclasses(class, file, raw)

    superclasses(class, file, raw)

    freeform_relationships(class, file, raw)

    IO.write(file, "___\n")
    navigation(file, raw, index)
  end

  def definition(class, file) do
    if class["definition"] do
      IO.write(file, "**Definition:** #{class["definition"]}\n")
      IO.write(file, "\n")
    end
  end

  def plural_name(class, file) do
    IO.write(file, "# #{class["plural_name"]}\n")
    IO.write(file, "\n")
  end

  def attributes(class, file) do
    if class["attributes"] do
      IO.write(file, "**Attributes:**\n")

      Enum.each(class["attributes"], fn (attribute) ->
        IO.write(file, "  * #{attribute}  \n")
      end)

      IO.write(file, "\n")
    end
  end

  def examples(class, file) do
    if class["examples"] do
      IO.write(file, "**Examples:**\n")

      Enum.each(class["examples"], fn (example) ->
        IO.write(file, "  * '#{example}'  \n")
      end)

      IO.write(file, "\n")
    end
  end

  def subclasses(class, file, raw) do
    subclasses_ = Helpers.subclasses(class, raw)

    if Enum.any?(subclasses_) do
      IO.write(file, "**Include:**\n")

      Enum.each(subclasses_, fn (subclass) ->
        label_ =
          if subclass["singleton"] do
            subclass["singular_name"]
          else
            subclass["plural_name"]
          end

        to_write = "  * [#{label_}](#{Helpers.entity_class_filename(subclass)})" <>
          "#{Helpers.formatted_examples(subclass)}  \n"

        IO.write(
          file,
          to_write
        )
        subsubclasses(file, subclass, raw)
      end)

      IO.write(file, "\n")
    end
  end

  def freeform_relationships(class, file, raw) do
    relevant_freeform_relationships_ = Helpers.relevant_freeform_relationships(
      class,
      raw
    )

    if Enum.any?(relevant_freeform_relationships_) do
      IO.write(file, "**Relationships:**\n")

      Enum.each(relevant_freeform_relationships_, fn (relationship) ->

        IO.write(file, "  * #{relationship}\n")
      end)

      IO.write(file, "\n")
    end
  end

  def superclasses(class, file, raw) do
    superclasses_ = Helpers.superclasses(class, raw)
    if Enum.any?(superclasses_) do
      IO.write(file, "**Are a subset of:**\n")

      Enum.each(superclasses_, fn (superclass) ->
        label_ =
          if superclass["singleton"] do
            "The #{superclass["singular_name"]}"
          else
            superclass["plural_name"]
          end

        IO.write(
          file,
          "  * [#{label_}](#{Helpers.entity_class_filename(superclass)})  \n"
        )
      end)

      IO.write(file, "\n")
    end
  end

  def subsubclasses(
    io,
    class,
    raw,
    level \\ 2
  ) do
    Helpers.subclasses(class, raw)
      |> Enum.each(fn (subclass) ->
        label = if subclass["singleton"] do
            subclass["singular_name"]
          else
            subclass["plural_name"]
          end

        to_write = "#{String.duplicate(" ", level * 2)}* [#{label}]" <>
          "(#{Helpers.entity_class_filename(subclass)})" <>
          "#{Helpers.formatted_examples(subclass)}  \n"

        IO.write(
          io,
          to_write
        )

        subsubclasses(
          io,
          subclass,
          raw,
          level + 1
        )
      end)
  end

  def navigation(io, raw, index) do
    previous = Enum.at(raw.entity_classes, index - 1)

    IO.write(io, "[[< Previous]](#{Helpers.entity_class_filename(previous)})")
    IO.write(io, " [[-- Index --]](entity_class_index.md) ")

    next_index =
      if index == Enum.count(raw.entity_classes) - 1 do
        0
      else
        index + 1
      end

    next = Enum.at(raw.entity_classes, next_index)
    IO.write(io, "[[Next >]](#{Helpers.entity_class_filename(next)})")

    IO.write(io, "\n")
  end
end