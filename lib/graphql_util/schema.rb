# frozen_string_literal: true

require 'fileutils'
require 'graphql/client'

class GraphqlUtil::Schema
  #
  # Initialize the GraphqlUtil::Schema to generate or retrieve the GraphQL Schema dump
  #
  # @param [GraphqlUtil::Http] http HTTP Client instance
  # @param [String] path Path to the client Class
  #
  def initialize(http, path:)
    @http = http
    @path = path
  end

  #
  # Loads the GraphQL Endpoint Introspection Schema from a dumped file if present, or dumps itself if needed
  #
  # @return [Class] GraphQL Schema
  #
  def load_schema
    if !File.exist?(@path)
      schema_dir = File.dirname(@path)
      FileUtils.mkdir_p(schema_dir) unless File.directory?(schema_dir)
      GraphQL::Client.dump_schema(@http, @path)
    end

    GraphQL::Client.load_schema(@path)
  end
end
