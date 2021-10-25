# frozen_string_literal: true

require 'graphql/client/http'

class GraphqlUtil::Http < GraphQL::Client::HTTP
  attr_accessor :token
  #
  # Returns the GraphQL::Client::HTTP instance injecting the PulsarAuthUtil authentication Token
  #
  # @param [String] endpoint GraphQL API Endpoint
  # @param [Hash] headers HTTP Request headers
  #
  def initialize(endpoint:, headers: {})
    @headers = headers
    super(endpoint) do
      def headers(context)
        @headers
      end
    end
  end
end
