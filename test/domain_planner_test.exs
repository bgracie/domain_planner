defmodule DomainPlannerTest do
  use ExUnit.Case

  test "Compiles the example" do
    Mix.Tasks.DomainPlanner.CompileExample.run([])
  end
end
