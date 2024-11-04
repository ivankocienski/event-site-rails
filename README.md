# README

A WIP project that models a very basic "event listing" site.

## Requirements
- ruby (>= 3)
- git (for cloning)
- [rbenv](https://github.com/rbenv/rbenv), [rbenv-gemset](https://github.com/jf/rbenv-gemset) and [ruby-build](https://github.com/rbenv/ruby-build) (not needed but helpful)
- gcc
- sqlite3 and dev libs
- opensearch (or docker)
- (probably other binary dependencies gems rely on)

## Pulling Placecal Data

The PC dataset needs to be downloaded periodically to stay up-to-date. This is just a small binary script that is run by `bin/snapshot-placecal` - it's output lives in the repo in `db/snapshots` and the data loading scripts automatically use the latest snapshot. This does not load anything in the database or do any of the processing steps mentioned below.

## Preflight

Given the correct ruby version is installed and the OpenSearch server is running.

```
  cd ${project_dir}
  bundle
  rails db:migrate
  rails db:import:placecal_snapshot # loads partners and events from PC snapshot
  rails db:import:load_keywords_and_tag_partners # loads keywords and classifies partners
  rails db:import:address_poscode_lookup # loads keywords and classifies partners
```

## To run

`cd` into directory and run `rails s` then navigate to http://localhost:3000

## Data disclaimer

The data from this project was pulled from the publicly available API provided by [PlaceCal](https://placecal.org/). No personal or private information is in this project.

