# frozen_string_literal: true

require 'optparse'
require_relative 'version'

module SQA
  module CLI
    # Main CLI dispatcher class
    class Dispatcher
      COMMANDS = %w[help version indicators show analyze backtest genetic pattern kbs stream optimize].freeze

      HELP_TEXT = <<~HELP
        SQA CLI - Simple Qualitative Analysis Command Line Interface

        A unified interface for financial market analysis using the SQA gem.

        Usage:
          sqa-cli <command> [options]

        Available Commands:
          help         Show this help message
          version      Show version information

        Analysis Commands:
          indicators   List all available TA-Lib technical indicators
          show         Display stock price data with technical indicators
          analyze      Run various analysis methods (FPOP, regime, seasonal)
          backtest     Run strategy backtests on historical data
          genetic      Evolve strategy parameters using genetic programming
          pattern      Discover profitable trading patterns
          kbs          Knowledge-based strategy using RETE inference
          stream       Simulate real-time price streaming
          optimize     Portfolio optimization and risk management

        Common Options:
          -h, --help      Show command-specific help
          -v, --verbose   Verbose output

        Examples:
          # Show version
          sqa-cli version

          # Show help
          sqa-cli help

          # Future examples (once commands are implemented):
          # sqa-cli backtest --ticker AAPL --strategy RSI
          # sqa-cli analyze --ticker AAPL --methods all
          # sqa-cli pattern --ticker AAPL --min-gain 10

        For command-specific help:
          sqa-cli <command> --help

        Documentation:
          https://github.com/MadBomber/sqa-cli
          https://github.com/MadBomber/sqa
      HELP
      private_constant :HELP_TEXT

      def self.run(args)
        new(args).execute
      end

      def initialize(args)
        @args = args
        @command = args.shift
      end

      HELP_ALIASES = ['help', '--help', '-h'].freeze
      private_constant :HELP_ALIASES

      VERSION_ALIASES = ['version', '--version', '-v'].freeze
      private_constant :VERSION_ALIASES

      def execute
        return help_result if @command.nil? || HELP_ALIASES.include?(@command)
        return version_result if VERSION_ALIASES.include?(@command)
        return unknown_command_result unless COMMANDS.include?(@command)

        run_command
      rescue LoadError => e
        load_error_result(e)
      rescue StandardError => e
        standard_error_result(e)
      end

      private

      def load_error_result(error)
        puts "Error: Command '#{@command}' not yet implemented"
        puts "Details: #{error.message}"
        1
      end

      def standard_error_result(error)
        puts "Error executing command: #{error.message}"
        puts error.backtrace.first(5)
        1
      end

      def help_result
        show_help
        0
      end

      def version_result
        puts "sqa-cli version #{VERSION}"
        0
      end

      def unknown_command_result
        puts "Error: Unknown command '#{@command}'"
        puts "\nRun 'sqa-cli help' for usage information."
        1
      end

      def run_command
        require_relative "commands/#{@command}"
        command_class = SQA::CLI::Commands.const_get(camelize(@command))
        command_class.new(@args).execute
        0
      end

      def show_help
        puts HELP_TEXT
      end

      def camelize(string)
        string.split('_').map(&:capitalize).join
      end
    end
  end
end
