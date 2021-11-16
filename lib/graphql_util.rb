# frozen_string_literal: true

require 'graphql_util/version'
require 'graphql_util/client'
require 'graphql_util/http'
require 'graphql_util/schema'

module GraphqlUtil
  #
  # Allows a Ruby class to behave like a GraphQL Client by extending it with the required methods and constants to perform GraphQL Queries / Mutations.
  #
  # * Extends the class with the required methods and constants to perform GraphQL Queries / Mutations
  # * Dumps the GraphQL Schema into the passed folder
  # * Dynamically defines constants and methods to perform the queries defined as .graphql files under /queries folder under the passed path
  #
  # @param [Class] base Class
  # @param [String] endpoint GraphQL API Endpoint
  # @param [String] path GraphQL Schema / Queries definitions path
  # @param [Hash] headers HTTP Request Headers
  #
  # @return [Boolean] true
  #
  def self.act_as_graphql_client(base, endpoint:, path:, headers: {})
    raise 'GraphqlUtil - Constant HTTP is already defined' if defined?(base::HTTP)
    raise 'GraphqlUtil - Constant SCHEMA is already defined' if defined?(base::SCHEMA)
    raise 'GraphqlUtil - Constant CLIENT is already defined' if defined?(base::CLIENT)
    raise 'GraphqlUtil - Constant GRAPHQL_SCHEMA_DUMP is already defined' if defined?(base::GRAPHQL_SCHEMA_DUMP)

    base.const_set('GRAPHQL_SCHEMA_DUMP', "#{path}/schema.json")
    base.const_set('HTTP', GraphqlUtil::Http.new(endpoint: endpoint, headers: headers))
    base.const_set('SCHEMA', GraphqlUtil::Schema.new(base::HTTP, path: base::GRAPHQL_SCHEMA_DUMP))
    base.const_set('CLIENT', GraphqlUtil::Client.new(schema: base::SCHEMA.load_schema, execute: base::HTTP))
    base.extend GraphqlUtilMethods

    Dir["#{path}/**/*.graphql"].each do |filename|
      const_name = filename.split('/').last.gsub('.graphql', '')

      base.const_set(const_name.upcase, base::CLIENT.parse(File.open(filename).read))
      base.define_singleton_method(const_name.downcase.to_sym) do |variables = {}|
        base.query(base.const_get(const_name.upcase.to_sym), variables: variables)
      end
    end

    true
  end

  module GraphqlUtilMethods
    #
    # Calls the Client query method to perform the passed GraphQL Query / Mutation request with variables
    #
    # @param [ParsedQuery] query GraphQL Parsed Query/Mutation
    # @param [Hash] variables Variables to be passed to the GraphQL Query / Mutation
    #
    # @return [Monad] Succes(:data) / Failure(:messages, :problems)
    #
    def query(query, variables: {})
      self::CLIENT.query(query, variables: variables)
    end
  end
end
