![logo](https://user-images.githubusercontent.com/50866745/138700181-01b54097-b19c-4655-b032-237c1a77a1fb.png)

![](https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white)
# GraphQL Util

The gem wraps the Ruby [graphql-client](https://github.com/github/graphql-client) gem, to dinamically define GraphQL Clients.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql_util'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install graphql_util

## Usage

Define a GraphQL client class, like so:

```Ruby
  class MyClient
    GraphqlUtil.act_as_graphql_client(
      self, # Required
      endpoint: 'https://api.github.com/graphql', # Required
      path: __dir__, # Required, (Recommended: __dir__)
      headers: {} # Optional
    )
  end
```

The `act_as_graphql_client` method accepts the following parameters:

1. `self`, which allows GraphqlUtil to inject the required code inside the class;
2. `endpoint`, which has to be the URL of the GraphQL endpoint;
3. `path`, which has to be the location where to store operations files and the Schema dump. (`__dir__` is the suggested one, but any valid path will do);
4. `headers`, a Hash of headers to be attached to any performed HTTP request.

As the class gets loaded, an Introspection Query request will get performed to the GraphQL endpoint in order to dump the API Schema.
You'll find your `schema.json` dump file under the above mentioned `path`.

To define queries and mutation, under the same location of your schema, create a folder named `queries`.
Any `.graphql` file listed under the `queries` folder will generate a class method inside your Client to perform the relative operation.

### Example

Let's take the following files structure as example:

```code
  path_to_graphql_client
  ├── queries
  │   └── user_info.graphql
  ├── my_client.rb
  └── schema.json
```

Where `my_client.rb` is the GraphQL Client class defined as above, `schema.json` is the GraphQL API Schema dump and `user_info.graphql` is a GraphQL query like this:

```GraphQL
  query userInfo($username: String!) {
    user(login: $username) {
      followers(first: 1) {
        totalCount
      }
    }
  }
```

Now that we've defined our first GraphQL query, the Client will automagically implement a method to perform such operation.
The method name will be the same as the filename, so if our file's named `user_info.graphql` the relative method will be `user_info`.

Each method will accept arguments as GraphQL variables.

### Example

```Ruby
  result = MyClient.user_info(username: 'LapoElisacci' )
```

You can find more details about the `graphql-client` [here](https://github.com/github/graphql-client)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LapoElisacci/graphql_util.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
