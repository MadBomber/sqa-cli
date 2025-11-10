# frozen_string_literal: true

require "test_helper"

class SQA::CLI::VersionTest < Minitest::Test
  def test_version_exists
    refute_nil SQA::CLI::VERSION
  end

  def test_version_format
    assert_match(/\d+\.\d+\.\d+/, SQA::CLI::VERSION)
  end
end
