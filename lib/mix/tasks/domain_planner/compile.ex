defmodule Mix.Tasks.DomainPlanner.Compile do
  # Compiles the plans using paths relative to the directory from which
  # the task is run

  use Mix.Task

  def run(args) do
    [ raw_dir, compiled_dir ] = args
    IO.puts "Raw dir: #{raw_dir}"
    IO.puts "Compiled dir: #{compiled_dir}"
  end
end