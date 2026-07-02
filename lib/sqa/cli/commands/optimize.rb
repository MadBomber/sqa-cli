#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Prints per-stock risk metrics (return, volatility, Sharpe, drawdown, VaR).
      # Extracted from Optimize because this reporting concern is independent of
      # the optimization workflow itself.
      module OptimizeRiskReport
        module_function

        def show_risk_metrics(stocks, returns_matrix, tickers, risk_free_rate)
          stocks.each_with_index do |stock, i|
            print_stock_risk_metrics(stock, returns_matrix[i], tickers[i], risk_free_rate)
          end
        end


        def print_stock_risk_metrics(stock, returns, ticker, risk_free_rate)
          puts "\n#{ticker}:"
          print_stock_return_stats(returns)
          print_stock_risk_ratios(returns, stock.df['adj_close_price'].to_a, risk_free_rate)
        end


        def print_stock_return_stats(returns)
          puts "  Annual Return: #{(returns.sum / returns.size * 252 * 100).round(2)}%"
          puts "  Volatility: #{(returns.std_dev * Math.sqrt(252) * 100).round(2)}%"
        end


        def print_stock_risk_ratios(returns, prices, risk_free_rate)
          sharpe = SQA::RiskManager.sharpe_ratio(returns, risk_free_rate: risk_free_rate)
          max_drawdown = SQA::RiskManager.max_drawdown(prices)[:max_drawdown]
          var = SQA::RiskManager.var(returns, confidence: 0.95)

          puts "  Sharpe Ratio: #{sharpe.round(2)}"
          puts "  Max Drawdown: #{(max_drawdown * 100).round(2)}%"
          puts "  VaR (95%): #{(var * 100).round(2)}%"
        end
      end


      # Loads SQA::Stock objects for a list of tickers and derives their returns
      # matrix. Extracted from Optimize because data loading is a distinct
      # responsibility from the optimization/reporting workflow.
      module OptimizeStockLoader
        module_function

        def load_stocks(tickers, verbose)
          # Load SQA on first use
          require 'sqa' unless defined?(SQA)

          stocks = tickers.map { |ticker| load_one_stock(ticker, verbose) }.compact

          if stocks.empty?
            puts 'Error: No stocks could be loaded'
            exit 1
          end

          puts "Loaded #{stocks.size} stocks"
          stocks
        end


        def load_one_stock(ticker, verbose)
          puts "  Loading #{ticker}..." if verbose
          SQA.init unless defined?(SQA::Stock)
          SQA::Stock.new(ticker: ticker)
        rescue StandardError => e
          puts "  Failed to load #{ticker}: #{e.message}"
          nil
        end


        def calculate_returns_matrix(stocks)
          stocks.map do |stock|
            prices = stock.df['adj_close_price'].to_a
            prices.each_cons(2).map { |a, b| (b - a) / a }
          end
        end
      end


      # Prints the final optimization result (allocation weights and expected
      # performance). Extracted from Optimize because this reporting concern is
      # independent of the optimization workflow itself.
      module OptimizeResultReport
        module_function

        def print_optimization_results(result, tickers)
          print_allocation(result, tickers)
          print_expected_performance(result)
        end


        def print_allocation(result, tickers)
          puts "\nOptimal Portfolio Allocation:"
          puts '-' * 50
          tickers.each_with_index do |ticker, i|
            weight = result[:weights][i]
            puts "  #{ticker.ljust(10)} #{(weight * 100).round(2)}%"
          end
        end


        def print_expected_performance(result)
          puts "\nExpected Performance:"
          puts "  Return: #{(result[:return] * 100).round(2)}% (annualized)"
          puts "  Volatility: #{(result[:volatility] * 100).round(2)}%"
          puts "  Sharpe Ratio: #{result[:sharpe].round(2)}" if result[:sharpe]
        end
      end


      # Prints the efficient frontier table and its maximum-Sharpe point.
      # Extracted from Optimize because this reporting concern is independent of
      # the rest of the optimization workflow.
      module OptimizeFrontierReport
        module_function

        def run_efficient_frontier(returns_matrix)
          puts "\nCalculating efficient frontier..."

          frontier = SQA::PortfolioOptimizer.efficient_frontier(returns_matrix, points: 20)

          print_frontier_table(frontier)
          print_max_sharpe_point(frontier)
        end


        def print_frontier_table(frontier)
          puts "\nEfficient Frontier (#{frontier.size} points):"
          puts '-' * 50
          puts "#{'Return'.ljust(12)} #{'Volatility'.ljust(12)} Sharpe"
          puts '-' * 50

          frontier.each { |point| print_frontier_point(point) }
        end


        def print_frontier_point(point)
          return_str = (point[:return] * 100).round(2).to_s.ljust(12)
          volatility_str = (point[:volatility] * 100).round(2).to_s.ljust(12)
          puts "#{return_str} #{volatility_str} #{point[:sharpe].round(2)}"
        end


        def print_max_sharpe_point(frontier)
          max_sharpe_point = frontier.max_by { |p| p[:sharpe] }
          puts "\nMaximum Sharpe Ratio Point:"
          puts "  Return: #{(max_sharpe_point[:return] * 100).round(2)}%"
          puts "  Volatility: #{(max_sharpe_point[:volatility] * 100).round(2)}%"
          puts "  Sharpe: #{max_sharpe_point[:sharpe].round(2)}"
        end
      end


      OPTIMIZE_METHODS = %w[sharpe variance risk_parity efficient_frontier].freeze

      OPTIMIZE_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli optimize [options]

        Portfolio optimization and risk management across multiple stocks.

        Options:
      BANNER

      # Optimize command - Portfolio optimization and risk management
      class Optimize < Base
        include OptimizeRiskReport
        include OptimizeFrontierReport
        include OptimizeStockLoader
        include OptimizeResultReport

        private

        def default_options
          super.merge(
            tickers: %w[AAPL MSFT GOOGL],
            method: 'sharpe',
            risk_free_rate: 0.02,
            target_return: nil,
            risk_metrics: false
          )
        end


        def add_command_options(opts)
          add_portfolio_options(opts)
          add_risk_options(opts)
        end


        def add_portfolio_options(opts)
          opts.on('--tickers LIST', Array,
                  'Comma-separated list of tickers (default: AAPL,MSFT,GOOGL)') do |tickers|
            @options[:tickers] = tickers.map(&:upcase)
          end

          opts.on('-m', '--method METHOD', OPTIMIZE_METHODS, 'Optimization method:',
                  "  #{OPTIMIZE_METHODS.join(', ')}") do |method|
            @options[:method] = method
          end
        end


        def add_risk_options(opts)
          opts.on('--risk-free-rate RATE', Float, 'Risk-free rate (default: 0.02)') do |rate|
            @options[:risk_free_rate] = rate
          end

          opts.on('--target-return RETURN', Float, 'Target return for optimization') do |target|
            @options[:target_return] = target
          end

          opts.on('--risk-metrics', 'Show risk metrics for each stock') do
            @options[:risk_metrics] = true
          end
        end


        def banner
          OPTIMIZE_BANNER_TEXT
        end

        public

        def execute
          print_header 'Portfolio Optimization'
          print_optimization_intro

          stocks, returns_matrix = load_stocks_and_returns
          maybe_show_risk_metrics(stocks, returns_matrix)

          print_section "Running Optimization (#{@options[:method]})"
          result = run_optimization(returns_matrix)
          return if result.nil?

          print_optimization_results(result, @options[:tickers])
        end

        private

        def load_stocks_and_returns
          print_section 'Loading Stock Data'
          stocks = load_stocks(@options[:tickers], @options[:verbose])

          print_section 'Calculating Returns'
          [stocks, calculate_returns_matrix(stocks)]
        end


        def maybe_show_risk_metrics(stocks, returns_matrix)
          return unless @options[:risk_metrics]

          print_section 'Individual Stock Risk Metrics'
          show_risk_metrics(stocks, returns_matrix, @options[:tickers], @options[:risk_free_rate])
        end


        def print_optimization_intro
          puts "\nTickers: #{@options[:tickers].join(', ')}"
          puts "Method: #{@options[:method]}"
          puts
        end


        def run_optimization(returns_matrix)
          case @options[:method]
          when 'sharpe' then optimize_sharpe(returns_matrix)
          when 'variance' then SQA::PortfolioOptimizer.minimum_variance(returns_matrix)
          when 'risk_parity' then SQA::PortfolioOptimizer.risk_parity(returns_matrix)
          when 'efficient_frontier' then run_efficient_frontier(returns_matrix) && nil
          else unknown_optimization_method
          end
        end


        def optimize_sharpe(returns_matrix)
          SQA::PortfolioOptimizer.maximum_sharpe(
            returns_matrix,
            risk_free_rate: @options[:risk_free_rate]
          )
        end


        def unknown_optimization_method
          puts "Unknown optimization method: #{@options[:method]}"
          exit 1
        end
      end
    end
  end
end
