# frozen_string_literal: true

require 'fileutils'
require 'graphql/client'

class GraphqlUtil::Schema
  def initialize(http, path:)
    @http = http
    @path = path
  end

  #
  # Loads the GraphQL Endpoint Introspection Schema from a dumped file if present, or dumps itself if needed
  #
  # @param [Boolean] force Force Introspection to override the dumped schema file
  #
  # @return [GraphQL::Schema] GraphQL Schema
  #
  def load_schema(force: false)
    if !File.exist?(@path) || force
      schema_dir = File.dirname(@path)
      FileUtils.mkdir_p(schema_dir) unless File.directory?(schema_dir)
      GraphQL::Client.dump_schema(@http, @path)
    end
    GraphQL::Client.load_schema(@path)
  end
end
