# frozen_string_literal: true

require 'graphql/client/http'

class GraphqlUtil::Http < GraphQL::Client::HTTP
  attr_accessor :token
  #
  # Returns the GraphQL::Client::HTTP instance injecting the PulsarAuthUtil authentication Token
  #
  # @param [String] endpoint GraphQL API Endpoint
  # @param [String] token GraphQL API Authentication Token
  #
  def initialize(endpoint, token)
    @token = token
    super(endpoint) do
      def headers(context)
        @token.present? ? { 'Authorization' => "Bearer #{@token}" } : {}
      end
    end
  end
end
