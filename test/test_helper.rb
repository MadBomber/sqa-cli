# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_group 'CLI', 'lib/sqa/cli'
end

# Load CLI components only (don't load the full SQA gem for tests)
require_relative '../lib/sqa/cli/version'
require_relative '../lib/sqa/cli/dispatcher'

require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, slow_count: 5)
]
