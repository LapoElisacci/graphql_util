# frozen_string_literal: true

require 'graphql_util/version'
require 'graphql_util/client'
require 'graphql_util/http'
require 'graphql_util/schema'

module GraphqlUtil
  class Error < StandardError; end

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
  #
  # @return [Boolean] true
  #
  def self.act_as_graphql_client(base, endpoint:, path:)
    raise 'GraphqlUtil - Contant GRAPHQL_UTIL_GRAPHQL_ENDPOINT is already defined' if defined?(base::GRAPHQL_UTIL_GRAPHQL_ENDPOINT)
    raise 'GraphqlUtil - Contant GRAPHQL_UTIL_GRAPHQL_PATH is already defined' if defined?(base::GRAPHQL_UTIL_GRAPHQL_PATH)
    raise 'GraphqlUtil - Contant GRAPHQL_UTIL_GRAPHQL_TOKEN is already defined' if defined?(base::GRAPHQL_UTIL_GRAPHQL_TOKEN)

    base.const_set('GRAPHQL_UTIL_GRAPHQL_ENDPOINT', endpoint)
    base.const_set('GRAPHQL_UTIL_GRAPHQL_PATH', path)
    # base.const_set('GRAPHQL_UTIL_GRAPHQL_TOKEN', token)
    base.extend GraphqlMethods

    base_client = base.client
    Dir.children("#{path}/queries").each do |query|
      raise "GraphqlUtil error - Invalid file #{query} found! Expected file extension to be .graphql" unless query.match(/.graphql/)
      const_name = query.gsub('.graphql', '')
      begin
        base.const_set(const_name.upcase, base_client.parse(File.open("#{path}/queries/#{query}").read))
        base.define_singleton_method(const_name.downcase.to_sym) do |params|
          base.query(base.const_get(const_name.upcase.to_sym), **params)
        end
      rescue StandardError => e
        message = "GraphqlUtil error - Could not define query method '#{const_name.downcase}' because of an error (#{e.message})."
        puts message
        LoggerUtil.logger.error(msg: message, e: e)
      end
    end
    true
  end

  module GraphqlMethods
    #
    # Returns the GraphQL client instance which can be used to perform GraphQL queries
    #
    # @return [GraphqlUtil::Client] Client instance
    #
    def client
      GraphqlUtil::Client.new(schema: schema.load_schema, execute: http)
    end

    #
    # Returns the HTTP Client instance based on the desired GraphQL API endpoint, required by the Client to perform requests
    #
    # @return [GraphqlUtil::Http] Required HTTP Client
    #
    def http
      GraphqlUtil::Http.new(self::GRAPHQL_UTIL_GRAPHQL_ENDPOINT, self::GRAPHQL_UTIL_GRAPHQL_TOKEN)
    end

    #
    # Calls the Client query method to perform the passed GraphQL Query / Mutation request with variables
    #
    # @param [ParsedQuery] query GraphQL Parsed Query/Mutation
    # @param [Hash] variables Variables to be passed to the GraphQL Query / Mutation
    #
    # @return [Monad] Succes(:data) / Failure(:messages, :problems)
    #
    def query(query, variables: {}, context: {})
      client.query(query, variables: variables, context: context)
    end

    #
    # Returns the GraphQL Schema instance, required by the GraphQL Client to perform Queries / Mutations
    #
    # @return [GraphqlUtil::Schema] Schema instance
    #
    def schema
      GraphqlUtil::Schema.new(http, path: "#{self::GRAPHQL_UTIL_GRAPHQL_PATH}/schema.json")
    end
  end
end
