# Partner Search Notes

Very much a **WORK IN PROGRESS**.

This is getting fairly complex with a lot of "in air" ideas that I'd like to get down before cleaning up all the hacky code I have written.

Elastic Search and OpenSearch are the same thing. They can be run locally in a docker container (see `/docker/search`) but in production they are normally a service you connect to (by HTTPS). Written in Java.

The way these things work is they ingest all your data into indices and then you query them and get back all that data - so synchronising your DB with your index is a chore that must be done.

Searchkick is a gem that wraps OS and ES and makes them slightly less cumbersome but more Rails specific.

## Resources
- [OS docs](https://opensearch.org/docs/latest/getting-started/)
- [Cheat sheet](https://gist.github.com/ruanbekker/e8a09604b14f37e8d2f743a87b930f93)
- [SearchKick](https://github.com/ankane/searchkick)

## Operation

There are two parts to search: ingesting and search.

### Ingesting data

### Search

Very complicated (powerful) API that boils down to:

```ruby
  partners = Partner.search(name_value, <options>)
  # the SearchKick way
```

Where options is a DSL.

#### Finding documents by string

```
(but in `bool` field?)

  multi-match
    "analyzer": "searchkick_search"
    "analyzer": "searchkick_search2"

  (with)
    boost set to 10 and 1
    "fuzziness": not set and 1
    "fuzzy_transpositions": true,
    "prefix_length": 0,
    "max_expansions": 3,

```

#### Filtering documents

#### Ordering output


