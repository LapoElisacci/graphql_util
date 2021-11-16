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
  class Client
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

### Schema

The very first time the Client class loads, an Introspection Query will be performed agains the GraphQL endpoint to dump the relative Schema.
You'll find your `schema.json` dump file under the above mentioned `path`.

(Remember that the Graphql Schema may change over time, therefore whenever you need to update the dump, simply delete the file. The new version will get created later.)

### Queries and Mutations

The Graphql operations you want your client to perform must be defined inside `.graphql` files under any `dir` subdirectory.

### Example and Best practise

Let's take the Github Graphql API as an example.

1. First we create a directory (a Ruby module) named `github` to contain all the necessary code.
2. We then create a file called `client.rb` , just like this:

```Ruby
  module Github
    class Client
      GraphqlUtil.act_as_graphql_client(
        self,
        endpoint: 'https://api.github.com/graphql',
        path: __dir__,
        headers: { # You can place any HTTP Header here
          'Authorization': GITHUB_TOKEN
        }
      )
    end
  end
```

3. Now we need to define our Queries / Mutations, to do so, place each operation definition under one (or many) subdirectory(ies), like this:

`github/queries/user_info.graphql`
```GraphQL
  query userInfo($username: String!) {
    user(login: $username) {
      followers(first: 1) {
        totalCount
      }
    }
  }
```

or

`github/mutations/add_comment.graphql`
```GraphQL
  mutation addComment($input: AddCommentInput!) {
    clientMutaitonId
  }
```

4. Now we have a file structure that looks like this:

```Code
  github
  ├── queries
  │   └── user_info.graphql
  ├── mutations
  │   └── add_comment.graphql
  ├── client.rb
  └── schema.json
```

5. Each defined operation generates a class method inside our client to perform the relative request. In our example `.user_info` & `.add_comment`.
6. Each defined method will accept arguments to be passed as variables.

```Ruby
Github::Client.user_info(username: 'LapoElisacci')
```

or

```Ruby
Github::Client.add_comment(input: { body: 'This gem is awesome!', subjectId: '12345678' })
```

## Constraints

The client Class as well as the sudirectories names are up to you, but only one level nesting is allowed.
Something like `anywhere/anything/whatever/whatever.graphql` won't produce the relative method, but `anywhere/anything/whatever.graphql` will, as long as `anywhere/whatever.rb` is the class that "act_as_graphql_client".

```Code
  anywhere
  ├── anything
  │   ├── wont_work
  │   │   └── wont_work.graphql
  │   └── anything_that_works.graphql
  ├── anything_2
  │   └── anything_that_works_too.graphql
  ├── whatever.rb
  └── schema.json
```

You can find more details about the `graphql-client` [here](https://github.com/github/graphql-client).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/LapoElisacci/graphql_util.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
