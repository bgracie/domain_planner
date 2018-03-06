defmodule DomainPlanner do
  def compile(raw_dir, compiled_dir) do
    Application.start(:yamerl)

    File.rm_rf("#{compiled_dir}/.")

    DomainPlanner.Write._(
      compiled_dir,
      DomainPlanner.Parse._(raw_dir)
    )
  end
end
