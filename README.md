# Dune [![shellandbull](https://circleci.com/gh/shellandbull/dune.svg?style=svg)](<LINK>)

Welcome to the Ruby SDK of the [Dune Analytics API](https://dune.com/docs/api/)

## Installation

`dune` is available as a gem on [Rubygems](https://rubygems.org/) To install it, add it to your `Gemfile`

```ruby
source "https://rubygems.org"

gem "dune"
```

## Usage

To use the Dune API you'll need to request an API key. The Dune API is currently in private beta.

**[Official API Documentation](https://dune.com/docs/api/)**

#### Setting up the client

The underlying HTTP client is [Faraday](https://lostisland.github.io/faraday/)

Here's the properties that can be provided to the constructor

| property           | required | description                                      |
|--------------------|----------|--------------------------------------------------|
| `api_key`          | true     | the API key                                      |
| `faraday_settings` | false    | a hash provided to `Faraday.new`                 |
| `logger`           | false    | an instance of Logger, defaults to a null logger |

```ruby
require "dune"

dune = Dune::Client.new(api_key: ENV["DUNE_API_KEY"])
dune.connection #=> returns a Faraday::Connection
```

#### Available methods

All methods will return the parsed JSON response as a hash.

Should the request fail the call will fail with a `Dune::Error` that contains the faraday `response` as a property

```ruby
dune = Dune::Client.new(api_key: ENV["DUNE_API_KEY"])

# execute a query
query_id          = 312527 # https://dune.com/queries/312527
query_response    = dune.query(query_id) # calls POST /query/312527/execute

# get status of a query
dune.execution_status(query_response["execution_id"]) # calls GET /execution/312527/status

# get the results of an execution
dune.execution(query_response["execution_id"]) # calls GET/execution/312527/results

# cancel an execution
dune.cancel(query_response["execution_id"]) # calls POST /execution/312527/cancel
```

#### Supplying parameters

Supplying parameters works by invoking the same `query` method. Make sure your query in Dune accepts parameters.

```ruby
dex_by_volume_query_id = 312527
json = JSON.generate({ query_parameters: { grouping_parameter: 2 } })
dune.query(dex_by_volume_query_id, json)
```
