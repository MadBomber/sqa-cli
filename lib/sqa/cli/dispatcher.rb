# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'version'

module SQA
  module CLI
    # Main CLI dispatcher class
    class Dispatcher
      COMMANDS = %w[help version indicators show analyze backtest genetic pattern kbs stream optimize].freeze

      def self.run(args)
        new(args).execute
      end

      def initialize(args)
        @args = args
        @command = args.shift
      end

      def execute
        # Show help if no command provided
        if @command.nil? || @command == 'help' || @command == '--help' || @command == '-h'
          show_help
          return 0
        end

        # Handle version
        if @command == 'version' || @command == '--version' || @command == '-v'
          puts "sqa-cli version #{VERSION}"
          return 0
        end

        # Validate command
        unless COMMANDS.include?(@command)
          puts "Error: Unknown command '#{@command}'"
          puts "\nRun 'sqa-cli help' for usage information."
          return 1
        end

        # Load and execute command
        require_relative "commands/#{@command}"
        command_class = SQA::CLI::Commands.const_get(camelize(@command))
        command_class.new(@args).execute
        0
      rescue LoadError => e
        puts "Error: Command '#{@command}' not yet implemented"
        puts "Details: #{e.message}"
        1
      rescue => e
        puts "Error executing command: #{e.message}"
        puts e.backtrace.first(5)
        1
      end

      private

      def show_help
        puts <<~HELP
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
      end

      def camelize(string)
        string.split('_').map(&:capitalize).join
      end
    end
  end
end
