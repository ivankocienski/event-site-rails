# README

A WIP project that models a very basic "event listing" site.

## Requirements
- ruby (>= 3)
- git (for cloning)
- [rbenv](https://github.com/rbenv/rbenv), [rbenv-gemset](https://github.com/jf/rbenv-gemset) and [ruby-build](https://github.com/rbenv/ruby-build) (not needed but helpful)
- gcc
- sqlite3
- (probably other binary dependencies gems rely on)

## Preflight

Given the correct ruby version is installed

```
  cd ${project_dir}
  bundle
  rails db:migrate
  rails db:import:partners # loads partners and events from PC snapshot
  rails db:import:load_and_tag_keywords # loads keywords and classifies partners
```

## To run

`cd` into directory and run `rails s` then navigate to http://localhost:3000

Note: This does not require any database (or javascript) at this time.

## Data disclaimer

The data from this project was pulled from the publicly available API provided by [PlaceCal](https://placecal.org/). No personal or private information is in this project.

