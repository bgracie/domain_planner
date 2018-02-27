defmodule Mix.Tasks.DomainPlanner.Compile do
  # Compiles the plans using paths relative to the directory from which
  # the task is run

  use Mix.Task

  def run(args) do
    [ raw_dir, compiled_dir ] = args

    DomainPlanner.compile(raw_dir, compiled_dir)
  end
end