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
  # * Dynamically defines constants and methods to perform the queries defined as .graphql files under under the passed path subdirectories
  #
  # @param [Class] base Class
  # @param [String] endpoint GraphQL API Endpoint
  # @param [String] path GraphQL Schema / Queries definitions path
  # @param [Hash] headers HTTP Request Headers
  #
  # @return [Boolean] true
  #
  def self.act_as_graphql_client(base, endpoint:, path:, headers: {})
    raise 'GraphqlUtil - Constant GRAPHQL_UTIL_HTTP is already defined' if defined?(base::GRAPHQL_UTIL_HTTP)
    raise 'GraphqlUtil - Constant GRAPHQL_UTIL_SCHEMA is already defined' if defined?(base::GRAPHQL_UTIL_SCHEMA)
    raise 'GraphqlUtil - Constant GRAPHQL_UTIL_CLIENT is already defined' if defined?(base::GRAPHQL_UTIL_CLIENT)
    raise 'GraphqlUtil - Constant GRAPHQL_UTIL_SCHEMA_DUMP is already defined' if defined?(base::GRAPHQL_UTIL_SCHEMA_DUMP)

    base.const_set('GRAPHQL_UTIL_SCHEMA_DUMP', "#{path}/schema.json")
    base.const_set('GRAPHQL_UTIL_HTTP', GraphqlUtil::Http.new(endpoint: endpoint, headers: headers))
    base.const_set('GRAPHQL_UTIL_SCHEMA', GraphqlUtil::Schema.new(base::GRAPHQL_UTIL_HTTP, path: base::GRAPHQL_UTIL_SCHEMA_DUMP))
    base.const_set('GRAPHQL_UTIL_CLIENT', GraphqlUtil::Client.new(schema: base::GRAPHQL_UTIL_SCHEMA.load_schema, execute: base::GRAPHQL_UTIL_HTTP))
    base.extend GraphqlUtilMethods

    Dir["#{path}/**/*.graphql"].each do |filename|
      const_name = filename.split('/').last.gsub('.graphql', '')
      raise "GraphqlUtil - #{const_name} is already defined, please use a different filename." if (base.const_get(const_name.upcase.to_sym).present? rescue false)

      base.const_set(const_name.upcase, base::GRAPHQL_UTIL_CLIENT.parse(File.open(filename).read))
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
    # @param [GraphQL::Client::OperationDefinition] query GraphQL Operation
    # @param [Hash] variables Variables to be passed to the GraphQL Query / Mutation
    #
    # @return [GraphQL::Client::Response] Request Response
    #
    def query(query, variables: {})
      self::GRAPHQL_UTIL_CLIENT.query(query, variables: variables)
    end
  end
end
