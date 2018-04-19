defmodule DomainPlanner.Parse do
  def exec(raw_dir) do
    %{
      entity_classes: entity_classes(raw_dir),
      type_relationships: type_relationships(raw_dir),
      freeform_relationships: freeform_relationships(raw_dir)
    }
  end

  def entity_classes(raw_dir) do
    "#{raw_dir}/entity_classes.yml"
      |> maybe_parse_file()
      |> strip_wrapper()
      |> ensure_not_null()
      |> Enum.map(&to_map/1)
      |> Enum.sort_by(fn (class) -> class["plural_name"] end)
  end

  def type_relationships(raw_dir) do
    "#{raw_dir}/type_relationships.yml"
      |> maybe_parse_file()
      |> strip_wrapper()
      |> ensure_not_null()
      |> Enum.map(&to_map/1)
  end

  def freeform_relationships(raw_dir) do
    "#{raw_dir}/freeform_relationships.yml"
      |> maybe_parse_file()
      |> strip_wrapper()
      |> ensure_not_null()
      |> Enum.map(&List.to_string/1)
  end

  def maybe_parse_file(path) do
    if File.exists?(path) do
      :yamerl_constr.file(path)
    else
      [[]]
    end
  end

  def strip_wrapper(yaml) do
    Enum.at(yaml, 0)
  end

  def ensure_not_null(yaml) do
    case yaml do
      :null -> []
      _ -> yaml
    end
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
end