#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Prints the strategy-comparison table and best-strategy summary.
      # Extracted from Backtest because this reporting concern only depends on
      # the collected comparison results, not on command options.
      module BacktestComparisonReport
        module_function

        def print_comparison_table(results_data)
          puts format(
            "\n%<strategy>-20s %<return>10s %<sharpe>10s %<drawdown>10s %<win_rate>10s %<trades>10s",
            strategy: 'Strategy', return: 'Return%', sharpe: 'Sharpe', drawdown: 'Drawdown%',
            win_rate: 'WinRate%', trades: 'Trades'
          )
          puts '-' * 70
          results_data.each { |r| print_comparison_row(r) }
        end


        def print_comparison_row(result)
          puts format(
            '%<strategy>-20s %<return>10.2f %<sharpe>10.2f %<drawdown>10.2f %<win_rate>10.2f %<trades>10d',
            result
          )
        end


        def print_best_strategy(results_data)
          best = results_data.first
          puts "\nBest Strategy: #{best[:strategy]} (#{best[:return].round(2)}% return)"
        end
      end


      # Runs a backtest for every known strategy and collects the results.
      # Extracted from Backtest because this is a distinct data-gathering
      # responsibility from the reporting/orchestration in Backtest itself.
      # `resolve_strategy` is injected as a callable so this module stays
      # independent of Backtest's strategy-name lookup table.
      module BacktestComparisonRunner
        module_function

        def collect_comparison_results(stock, strategy_names, run_config)
          strategy_names.map do |strategy_name|
            run_comparison_backtest(stock, strategy_name, run_config)
          end.compact
        end


        def run_comparison_backtest(stock, strategy_name, run_config)
          backtest = SQA::Backtest.new(
            stock: stock,
            strategy: run_config[:resolve_strategy].call(strategy_name),
            initial_capital: run_config[:capital],
            commission: run_config[:commission]
          )

          comparison_result(strategy_name, backtest.run)
        rescue StandardError => e
          puts "  Warning: #{strategy_name} failed: #{e.message}" if run_config[:verbose]
          nil
        end


        def comparison_result(strategy_name, results)
          {
            strategy: strategy_name,
            return: results.total_return,
            sharpe: results.sharpe_ratio,
            drawdown: results.max_drawdown,
            win_rate: results.win_rate,
            trades: results.total_trades
          }
        end
      end

      BACKTEST_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli backtest [options]

        Run strategy backtests on historical stock data.

        Options:
      BANNER

      # Backtest command - Run strategy backtests on historical data
      class Backtest < Base
        include BacktestComparisonReport
        include BacktestComparisonRunner

        STRATEGIES = %w[RSI SMA EMA MACD BollingerBands Stochastic VolumeBreakout KBS Consensus
                        Random].freeze

        private

        def default_options
          super.merge(
            strategy: 'RSI',
            capital: 10_000.0,
            commission: 1.0,
            compare: false
          )
        end


        def add_command_options(opts)
          opts.on('-s', '--strategy NAME', STRATEGIES, 'Strategy to backtest:',
                  "  #{STRATEGIES.join(', ')}") do |strategy|
            @options[:strategy] = strategy
          end

          add_cost_options(opts)

          opts.on('--compare', 'Compare against all strategies') do
            @options[:compare] = true
          end
        end


        def add_cost_options(opts)
          opts.on('-c', '--capital AMOUNT', Float, 'Initial capital (default: 10000)') do |capital|
            @options[:capital] = capital
          end

          opts.on('--commission AMOUNT', Float, 'Commission per trade (default: 1.0)') do |commission|
            @options[:commission] = commission
          end
        end


        def banner
          BACKTEST_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Backtesting #{@options[:strategy]} on #{@options[:ticker]}"

          if @options[:compare]
            compare_strategies(stock)
          else
            run_single_backtest(stock)
          end
        end

        private

        def run_single_backtest(stock)
          strategy_class = resolve_strategy(@options[:strategy])

          backtest = SQA::Backtest.new(
            stock: stock,
            strategy: strategy_class,
            initial_capital: @options[:capital],
            commission: @options[:commission]
          )

          results = backtest.run
          print_results(results)
        end


        def compare_strategies(stock)
          print_section 'Comparing All Strategies'

          run_config = {
            capital: @options[:capital], commission: @options[:commission],
            verbose: @options[:verbose], resolve_strategy: method(:resolve_strategy)
          }
          results_data = collect_comparison_results(stock, STRATEGIES, run_config)
          results_data.sort_by! { |r| -r[:return] }

          print_comparison_table(results_data)
          print_best_strategy(results_data)
        end


        STRATEGY_CLASSES = {
          'RSI' => 'SQA::Strategy::RSI',
          'SMA' => 'SQA::Strategy::SMA',
          'EMA' => 'SQA::Strategy::EMA',
          'MACD' => 'SQA::Strategy::MACD',
          'BOLLINGERBANDS' => 'SQA::Strategy::BollingerBands',
          'STOCHASTIC' => 'SQA::Strategy::Stochastic',
          'VOLUMEBREAKOUT' => 'SQA::Strategy::VolumeBreakout',
          'KBS' => 'SQA::Strategy::KBS',
          'CONSENSUS' => 'SQA::Strategy::Consensus',
          'RANDOM' => 'SQA::Strategy::Random'
        }.freeze
        private_constant :STRATEGY_CLASSES

        def resolve_strategy(name)
          class_name = STRATEGY_CLASSES[name.upcase]
          raise "Unknown strategy: #{name}" unless class_name

          Object.const_get(class_name)
        end
      end
    end
  end
end
