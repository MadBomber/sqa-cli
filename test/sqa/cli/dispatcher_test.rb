# frozen_string_literal: true

require "test_helper"

class SQA::CLI::DispatcherTest < Minitest::Test
  def test_run_with_no_arguments_shows_help
    output = capture_io do
      result = SQA::CLI::Dispatcher.run([])
      assert_equal 0, result
    end

    assert_match(/Usage:/, output.join)
  end

  def test_run_with_help_command
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['help'])
      assert_equal 0, result
    end

    assert_match(/Usage:/, output.join)
  end

  def test_run_with_help_flag
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['--help'])
      assert_equal 0, result
    end

    assert_match(/Usage:/, output.join)
  end

  def test_run_with_version_command
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['version'])
      assert_equal 0, result
    end

    assert_match(/version/, output.join)
  end

  def test_run_with_version_flag
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['--version'])
      assert_equal 0, result
    end

    assert_match(/version/, output.join)
  end

  def test_run_with_unknown_command
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['unknown'])
      assert_equal 1, result
    end

    assert_match(/Unknown command/, output.join)
  end
end
