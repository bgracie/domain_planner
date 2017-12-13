defmodule Mix.Tasks.DomainPlanner.Compile do

  use Mix.Task

  def run(args) do
    IO.puts Enum.at(args, 0)
  end
end