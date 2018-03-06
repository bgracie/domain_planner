# Domain Planner

This project is a tool for the high-level planning of a database-backed web app.
It is meant to organize a 'dictionary' of terminology for the project that is separate from
the physical modelling of the data.  The plans are written in YAML and compiled to a set of interlinked markdown documents (intended to be viewed in a web-based version control host such as Github or Gitlab).

## Writing The Plan

Please see [this folder](test/example/raw) for a sample set of YAML plans.

## Compiling The Plan

Run `mix domain_planner.compile raw_plans_directory compiled_plans directory`

## The result

Visit [this page](test/example/compiled/entity_class_index.md) to see the compiled example plans

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
