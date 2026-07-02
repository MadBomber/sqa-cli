#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Runs and prints a backtest for a single generated pattern strategy.
      # Extracted from Pattern because this concern only depends on the
      # strategy/stock/results being processed, not on command options.
      module PatternStrategyBacktestReport
        module_function

        def print_strategy_backtest(strategy, index, stock)
          puts "\n#{'-' * 70}"
          puts "Strategy ##{index + 1}"
          puts "Pattern: #{strategy.pattern}"
          puts

          results = run_pattern_backtest(strategy, stock)
          print_pattern_backtest_results(results)
        end


        def run_pattern_backtest(strategy, stock)
          backtest = SQA::Backtest.new(
            stock: stock,
            strategy: strategy,
            initial_capital: 10_000.0,
            commission: 1.0
          )

          backtest.run
        end


        def print_pattern_backtest_results(results)
          puts 'Backtest Results:'
          puts "  Total Return: #{results.total_return.round(2)}%"
          puts "  Sharpe Ratio: #{results.sharpe_ratio.round(2)}"
          puts "  Max Drawdown: #{results.max_drawdown.round(2)}%"
          puts "  Win Rate: #{results.win_rate.round(2)}%"
          puts "  Total Trades: #{results.total_trades}"
        end
      end

      PATTERN_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli pattern [options]

        Discover profitable trading patterns by reverse-engineering historical trades.
        Identifies indicator combinations at inflection points that preceded gains.

        Options:
      BANNER

      PATTERN_DEFAULT_OPTIONS = {
        min_gain: 10.0,
        fpop: 10,
        min_frequency: 3,
        inflection_window: 3,
        max_patterns: 10,
        export: nil,
        generate: false
      }.freeze

      # Pattern command - Discover profitable trading patterns
      class Pattern < Base
        include PatternStrategyBacktestReport

        private

        def default_options
          super.merge(PATTERN_DEFAULT_OPTIONS)
        end


        def add_command_options(opts)
          add_discovery_options(opts)
          add_output_options(opts)
        end


        def add_discovery_options(opts)
          opts.on('-g', '--min-gain PERCENT', Float, 'Minimum gain percent (default: 10.0)') do |gain|
            @options[:min_gain] = gain
          end

          opts.on('-f', '--fpop DAYS', Integer,
                  'Future period of performance in days (default: 10)') do |fpop|
            @options[:fpop] = fpop
          end

          add_frequency_options(opts)
        end


        def add_frequency_options(opts)
          opts.on('-m', '--min-frequency COUNT', Integer, 'Minimum pattern frequency (default: 3)') do |freq|
            @options[:min_frequency] = freq
          end

          opts.on('-w', '--window DAYS', Integer, 'Inflection detection window (default: 3)') do |window|
            @options[:inflection_window] = window
          end
        end


        def add_output_options(opts)
          opts.on('-n', '--max-patterns COUNT', Integer, 'Max patterns to display (default: 10)') do |max|
            @options[:max_patterns] = max
          end

          opts.on('-e', '--export FILE', 'Export patterns to CSV file') do |file|
            @options[:export] = file
          end

          opts.on('--generate', 'Generate and backtest strategies from patterns') do
            @options[:generate] = true
          end
        end


        def banner
          PATTERN_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Pattern Discovery for #{@options[:ticker]}"
          print_pattern_parameters

          generator = build_strategy_generator(stock)
          patterns = discover_patterns(generator)
          return if patterns.empty?

          print_discovered_patterns(generator)
          generate_strategies(generator, stock) if @options[:generate]
        end

        private

        def print_discovered_patterns(generator)
          print_section 'Discovered Patterns'
          generator.print_patterns(max_patterns: @options[:max_patterns])
          maybe_export_patterns(generator)
        end


        def print_pattern_parameters
          puts "\nParameters:"
          puts "  Minimum Gain: #{@options[:min_gain]}%"
          puts "  FPOP (Future Period): #{@options[:fpop]} days"
          puts "  Minimum Frequency: #{@options[:min_frequency]}"
          puts "  Inflection Window: #{@options[:inflection_window]} days"
        end


        def build_strategy_generator(stock)
          SQA::StrategyGenerator.new(
            stock: stock,
            min_gain_percent: @options[:min_gain],
            fpop: @options[:fpop],
            inflection_window: @options[:inflection_window]
          )
        end


        def discover_patterns(generator)
          print_section 'Discovering Patterns...'
          patterns = generator.discover_patterns(min_pattern_frequency: @options[:min_frequency])

          if patterns.empty?
            puts "\nNo patterns found with current parameters."
            puts 'Try adjusting --min-gain, --fpop, or --min-frequency'
          end

          patterns
        end


        def maybe_export_patterns(generator)
          return unless @options[:export]

          generator.export_patterns(@options[:export])
          puts "\nPatterns exported to: #{@options[:export]}"
        end


        def generate_strategies(generator, stock)
          print_section 'Generating Strategies from Top Patterns'

          strategies = generator.generate_strategies(top_n: 3, strategy_type: :class)

          if strategies.empty?
            puts 'No strategies could be generated'
            return
          end

          puts "\nGenerated #{strategies.size} strategies\n"
          strategies.each_with_index { |strategy, i| print_strategy_backtest(strategy, i, stock) }
        end
      end
    end
  end
end
