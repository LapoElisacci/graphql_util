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
  def initialize(endpoint:, token:, user_agent:)
    @token = token
    @user_agent = user_agent
    super(endpoint) do
      def headers(context)
        {
          'Authorization' => "Bearer #{@token}",
          'User-Agent' => @user_agent
        }
      end
    end
  end
end
