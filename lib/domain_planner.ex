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

    IO.inspect entity_classes
    IO.inspect type_relationships
    IO.inspect freeform_relationships
  end

  def to_map(tuple_list) do
    for { key, val } <- tuple_list, into: %{}, do: {key, val}
  end
end
