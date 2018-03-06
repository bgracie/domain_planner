defmodule DomainPlanner.Parse do
  def _(raw_dir) do
    %{
      entity_classes: entity_classes(raw_dir),
      type_relationships: type_relationships(raw_dir),
      freeform_relationships: freeform_relationships(raw_dir)
    }
  end

  def entity_classes(raw_dir) do
    "#{raw_dir}/entity_classes.yml"
      |> :yamerl_constr.file()
      |> Enum.at(0)
      |> Enum.map(&to_map/1)
      |> Enum.sort_by(fn (class) -> class["plural_name"] end)
  end

  def type_relationships(raw_dir) do
    "#{raw_dir}/type_relationships.yml"
      |> :yamerl_constr.file()
      |> Enum.at(0)
      |> Enum.map(&to_map/1)
  end

  def freeform_relationships(raw_dir) do
    "#{raw_dir}/freeform_relationships.yml"
      |> :yamerl_constr.file()
      |> Enum.at(0)
      |> Enum.map(&List.to_string/1)
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