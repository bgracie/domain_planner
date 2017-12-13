defmodule Mix.Tasks.DomainPlanner.CompileExample do
  # From the root of the project directory, compiles the examples

  use Mix.Task

  def run(_) do
    Mix.Tasks.DomainPlanner.Compile.run([
      "example/raw",
      "example/compiled"
    ])
  end
end