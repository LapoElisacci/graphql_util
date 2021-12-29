require_relative 'lib/graphql_util/version'

Gem::Specification.new do |spec|
  spec.name          = 'graphql_util'
  spec.version       = GraphqlUtil::VERSION
  spec.authors       = ['Elisacci Lapo']
  spec.email         = ['lapoelisacci@gmail.com']

  spec.summary       = 'Ruby GraphQL Client utility'
  spec.description   = 'GraphqlUtil allows you to dynamically define GraphQL Client'
  spec.homepage      = 'https://github.com/LapoElisacci/graphql_util'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.4.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LapoElisacci/graphql_util'
  spec.metadata['changelog_uri'] = 'https://github.com/LapoElisacci/graphql_util/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'graphql-client', '~> 0'
  spec.add_development_dependency 'byebug'
end
