# frozen_string_literal: true

require 'graphql/client'

class GraphqlUtil::Client < GraphQL::Client
  #
  # Performs a GraphQL Query and handles the response
  #
  # @param [String] parsed_query GraphQL parsed query
  # @param [Hash] variables GraphQL query params
  #
  # @return [GraphQL::Client::Response] Request Response
  #
  def query(parsed_query, variables: {})
    super(parsed_query, variables: variables, context: {})
  end
end
