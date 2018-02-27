defmodule DomainPlanner do
  @moduledoc """
  Documentation for DomainPlanner.
  """

  @doc """
  Hello world.

  ## Examples

      iex> DomainPlanner.hello
      :world

  """

  def compile(raw_dir, compiled_dir) do
    Application.start(:yamerl)

    entity_classes = :yamerl_constr.file("#{raw_dir}/entity_classes.yml")
      |> Enum.at(0)
      |> Enum.map(&to_map/1)

    type_relationships = :yamerl_constr.file("#{raw_dir}/type_relationships.yml")
      |> Enum.at(0)
      |> Enum.map(&to_map/1)

    freeform_relationships = :yamerl_constr.file("#{raw_dir}/freeform_relationships.yml")
      |> Enum.at(0)
      |> Enum.map(&List.to_string/1)

    File.rm_rf("#{compiled_dir}/.")

    write_index(compiled_dir, entity_classes)
    write_class_pages(
      compiled_dir,
      entity_classes,
      type_relationships,
      freeform_relationships
    )
  end

  def to_map(tuple_list) do
    for { key, val } <- tuple_list,
      into: %{},
      do: {List.to_string(key), convert_map_value(key, val)}
  end

  def convert_map_value(key, val) do
    if key === 'examples' || key == 'attributes' do
      Enum.map(val, &List.to_string/1)
    else
      List.to_string(val)
    end
  end

  def entity_class_filename(klass) do
    klass["plural_name"]
      |> String.replace(" ", "_", global: true)
      |> String.downcase
      |> (&(&1 <> ".md")).()
  end

  def find(klassname, entity_classes) do
    Enum.find(entity_classes, fn (klass) ->
      klass["singular_name"] == klassname || klass["plural_name"] == klassname
    end)
  end

  def subclasses(klass, entity_classes, type_relationships) do
    Enum.filter(type_relationships, fn (relationship) ->
      find(relationship["superclass"], entity_classes) == klass
    end) |> Enum.map(fn (relationship) ->
      find(relationship["subclass"], entity_classes)
    end)
  end

  def superclasses(klass, entity_classes, type_relationships) do
    Enum.filter(type_relationships, fn (relationship) ->
      find(relationship["subclass"], entity_classes) == klass
    end) |> Enum.map(fn (relationship) ->
      find(relationship["superclass"], entity_classes)
    end)
  end

  def formatted_examples(klass) do
    if klass["examples"] do
      examples = klass["examples"]
        |> Enum.map(fn (e) -> "'#{e}'" end)
        |> Enum.join(", ")

      " (e.g. #{examples})"
    else
      ""
    end
  end

  def navigation(io, entity_classes, index) do
    previous = Enum.at(entity_classes, index - 1)

    IO.write(io, "[[< Previous]](#{entity_class_filename(previous)})")
    IO.write(io, " [[-- Index --]](entity_class_index.md) ")

    next_index =
      if index == Enum.count(entity_classes) - 1 do
        0
      else
        index + 1
      end

    next = Enum.at(entity_classes, next_index)
    IO.write(io, "[[Next >]](#{entity_class_filename(next)})")

    IO.write(io, "\n")
  end

  def relevant_freeform_relationships(klass, entity_classes, type_relationships, freeform_relationships) do
    (Enum.filter(freeform_relationships, fn (relationship) ->
      String.contains?(relationship, "[#{klass["singular_name"]}]") ||
        String.contains?(relationship, "[#{klass["plural_name"]}]")
    end) |> Enum.map(fn (relationship) ->
      link_names = Regex.scan(~r/\[([\w\s]+)\]/, relationship)
        |> Enum.map(&Enum.at(&1, 0))
        |> Enum.map(&String.replace(&1, ~r/[\]\[]/, ""))

      Enum.reduce(link_names, relationship, fn (name, acc) ->
        i_class = find(name, entity_classes)

        examples =
          if klass == i_class || !i_class["examples"] do
            ""
          else
            formatted_examples(i_class)
          end

        String.replace(
          acc,
          "[#{name}]",
          "[#{name}](#{entity_class_filename(i_class)})#{examples}",
          global: true
        )
      end)
    end)) ++ (superclasses(klass, entity_classes, type_relationships)
      |> Enum.map(fn (superclass) ->
        relevant_freeform_relationships(
          superclass,
          entity_classes,
          type_relationships,
          freeform_relationships
        )
      end) |> List.flatten)
  end

  def write_subclasses(io, klass, entity_classes, type_relationships, level \\ 2) do
    subclasses(klass, entity_classes, type_relationships)
      |> Enum.each(fn (subclass) ->
        label = if subclass["singleton"] do
            subclass["singular_name"]
          else
            subclass["plural_name"]
          end

        IO.write(
          io,
          "#{String.duplicate(" ", level * 2)}* [#{label}](#{entity_class_filename(subclass)})#{formatted_examples(subclass)}  \n"
        )

        write_subclasses(io, subclass, entity_classes, type_relationships, level + 1)
      end)
  end

  def sorted_entity_classes(entity_classes) do
    Enum.sort_by(entity_classes, fn (class) -> class["plural_name"] end)
  end

  def write_index(compiled_path, entity_classes) do
    File.open("#{compiled_path}/entity_class_index.md", [:write], fn (file) ->
      IO.write(file, "# Entity Classes\n")
      IO.write(file, "\n")

      Enum.each(sorted_entity_classes(entity_classes), fn (class) ->

        IO.write(
          file,
          "  * [#{class["plural_name"]}](#{entity_class_filename(class)})  \n"
        )
      end)
    end)
  end

  def write_class_pages(
    compiled_dir,
    entity_classes,
    type_relationships,
    freeform_relationships
  ) do
    sorted_entity_classes(entity_classes)
    |> Stream.with_index
    |> Enum.each(fn ({elem, index}) ->
      write_class_page(
        elem,
        index,
        compiled_dir,
        entity_classes,
        type_relationships,
        freeform_relationships
      )
    end)
  end

  def write_class_page(
    klass,
    index,
    compiled_dir,
    entity_classes,
    type_relationships,
    freeform_relationships
  ) do
    File.open(
      "#{compiled_dir}/#{entity_class_filename(klass)}",
      [:write],
      fn (file) ->
        navigation(file, entity_classes, index)


        IO.write(file, "___\n")

        IO.write(file, "# #{klass["plural_name"]}\n")
        IO.write(file, "\n")

        if klass["definition"] do
          IO.write(file, "**Definition:** #{klass["definition"]}\n")
          IO.write(file, "\n")
        end

        if klass["attributes"] do
          IO.write(file, "**Attributes:**\n")

          Enum.each(klass["attributes"], fn (attribute) ->
            IO.write(file, "  * #{attribute}  \n")
          end)

          IO.write(file, "\n")
        end

        if klass["examples"] do
          IO.write(file, "**Examples:**\n")

          Enum.each(klass["examples"], fn (example) ->
            IO.write(file, "  * '#{example}'  \n")
          end)

          IO.write(file, "\n")
        end

        c_subclasses = subclasses(klass, entity_classes, type_relationships)

        if Enum.any?(c_subclasses) do
          IO.write(file, "**Include:**\n")

          Enum.each(c_subclasses, fn (subclass) ->
            l_label =
              if subclass["singleton"] do
                subclass["singular_name"]
              else
                subclass["plural_name"]
              end

            IO.write(file, "  * [#{l_label}](#{entity_class_filename(subclass)})#{formatted_examples(subclass)}  \n")
            write_subclasses(file, subclass, entity_classes, type_relationships)
          end)

          IO.write(file, "\n")
        end

        c_superclasses = superclasses(klass, entity_classes, type_relationships)
        if Enum.any?(c_superclasses) do
          IO.write(file, "**Are a subset of:**\n")

          Enum.each(c_superclasses, fn (superclass) ->
            l_label =
              if superclass["singleton"] do
                "The #{superclass["singular_name"]}"
              else
                superclass["plural_name"]
              end

            IO.write(file, "  * [#{l_label}](#{entity_class_filename(superclass)})  \n")
          end)

          IO.write(file, "\n")
        end

        c_relevant_freeform_relationships = relevant_freeform_relationships(klass, entity_classes, type_relationships, freeform_relationships)
        if Enum.any?(c_relevant_freeform_relationships) do
          IO.write(file, "**Relationships:**\n")

          Enum.each(c_relevant_freeform_relationships, fn (relationship) ->

            IO.write(file, "  * #{relationship}\n")
          end)

          IO.write(file, "\n")
        end

        IO.write(file, "___\n")
        navigation(file, entity_classes, index)
      end)
  end
end
