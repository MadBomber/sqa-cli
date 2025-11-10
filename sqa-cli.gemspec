# frozen_string_literal: true

require_relative "lib/sqa/cli/version"

Gem::Specification.new do |spec|
  spec.name          = "sqa-cli"
  spec.version       = SQA::CLI::VERSION
  spec.authors       = ["Dewayne VanHoozer"]
  spec.email         = ["dvanhoozer@gmail.com"]

  spec.summary       = "Command-line interface for financial market analysis"
  spec.description   = "A modular CLI for financial and stock market analysis using the SQA gem. Features include backtesting, pattern discovery, genetic programming, portfolio optimization, and real-time market analysis."
  spec.homepage      = "https://github.com/madbomber/sqa-cli"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]          = spec.homepage
  spec.metadata["source_code_uri"]       = "https://github.com/madbomber/sqa-cli"
  spec.metadata["changelog_uri"]         = "https://github.com/madbomber/sqa-cli/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"]     = "https://madbomber.github.io/sqa-cli"
  spec.metadata["bug_tracker_uri"]       = "https://github.com/madbomber/sqa-cli/issues"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir[
      "lib/**/*.rb",
      "bin/*",
      "README.md",
      "LICENSE.txt",
      "CHANGELOG.md"
    ].select { |f| File.file?(f) }
  end

  spec.bindir        = "bin"
  spec.executables   = ["sqa-cli"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "sqa", "~> 0.0.27"
  spec.add_dependency "debug_me", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "minitest-reporters", "~> 1.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.50"
  spec.add_development_dependency "rubocop-minitest", "~> 0.35"
end
