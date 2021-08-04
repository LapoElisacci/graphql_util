# forzen_string_literal: true

require 'graphql/client'

class GraphqlUtil::Client < GraphQL::Client
  #
  # Performs a GraphQL Query and handles the response
  #
  # @param [String] parsed_query GraphQL parsed query
  # @param [Hash] variables GraphQL query params
  # @param [Hash] context GraphQL query context
  #
  # @return [Monad] Succes(:data) / Failure(Exceptions::GraphqlError)
  #
  def query(parsed_query, variables: {}, context: {})
    super(parsed_query, variables: variables, context: context)
  end
end
