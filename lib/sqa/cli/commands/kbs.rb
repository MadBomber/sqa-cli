#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Builds the "custom" and "minimal" hand-authored KBS rule sets.
      # Extracted from Kbs because rule construction is a pure factory concern,
      # independent of command options.
      module KbsStrategyBuilder
        module_function

        def create_custom_strategy
          strategy = SQA::Strategy::KBS.new(load_defaults: false)

          add_aggressive_buy_rule(strategy)
          add_conservative_sell_rule(strategy)
          add_volume_breakout_rule(strategy)

          strategy
        end


        def add_aggressive_buy_rule(strategy)
          strategy.add_rule :aggressive_buy do
            on :rsi, { level: :oversold }
            on :stochastic, { zone: :oversold }
            on :bollinger, { position: :below }
            perform do
              kb.assert(:signal, { action: :buy, confidence: :high, reason: :triple_confirmation })
            end
          end
        end


        def add_conservative_sell_rule(strategy)
          strategy.add_rule :conservative_sell do
            on :rsi, { level: :overbought }
            on :trend, { short_term: :down }
            perform do
              kb.assert(:signal, { action: :sell, confidence: :medium, reason: :overbought_downtrend })
            end
          end
        end


        def add_volume_breakout_rule(strategy)
          strategy.add_rule :volume_breakout do
            on :trend, { short_term: :up, strength: :strong }
            on :volume, { level: :high }
            perform do
              kb.assert(:signal, { action: :buy, confidence: :high, reason: :volume_breakout })
            end
          end
        end


        def create_minimal_strategy
          strategy = SQA::Strategy::KBS.new(load_defaults: false)

          add_simple_rsi_rule(strategy)
          add_simple_macd_rule(strategy)

          strategy
        end


        def add_simple_rsi_rule(strategy)
          strategy.add_rule :simple_rsi do
            on :rsi, { level: :oversold }
            perform do
              kb.assert(:signal, { action: :buy, confidence: :medium, reason: :rsi_oversold })
            end
          end
        end


        def add_simple_macd_rule(strategy)
          strategy.add_rule :simple_macd do
            on :macd, { crossover: :bullish }
            perform do
              kb.assert(:signal, { action: :buy, confidence: :medium, reason: :macd_bullish })
            end
          end
        end
      end


      # Builds the OpenStruct data vector (prices, volumes, indicators) that
      # KBS strategies evaluate. Extracted from Kbs because vector construction
      # is a pure function of the stock's data, independent of command options.
      module KbsVectorBuilder
        module_function

        def build_data_vector(stock)
          prices = stock.df['adj_close_price'].to_a
          highs = stock.df['high_price'].to_a
          lows = stock.df['low_price'].to_a

          require 'ostruct'
          OpenStruct.new(
            base_vector_fields(stock, prices, highs, lows).merge(indicator_fields(prices, highs, lows))
          )
        end


        def base_vector_fields(stock, prices, highs, lows)
          { prices: prices, volumes: stock.df['volume'].to_a, highs: highs, lows: lows }
        end


        def indicator_fields(prices, highs, lows)
          {
            rsi: SQAI.rsi(prices, period: 14),
            macd: SQAI.macd(prices)
          }.merge(stochastic_and_bollinger_fields(prices, highs, lows))
        end


        def stochastic_and_bollinger_fields(prices, highs, lows)
          stoch = SQAI.stoch(highs, lows, prices)
          bbands = SQAI.bbands(prices)

          {
            stoch_k: stoch.first,
            stoch_d: stoch.last,
            bb_upper: bbands.first,
            bb_middle: bbands[1],
            bb_lower: bbands[2]
          }
        end
      end

      KBS_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli kbs [options]

        Run knowledge-based strategy using RETE forward-chaining inference.

        Options:
      BANNER

      # KBS command - Knowledge-Based Strategy with RETE
      class Kbs < Base
        include KbsStrategyBuilder
        include KbsVectorBuilder

        private

        def default_options
          super.merge(
            rules: 'default',
            show_rules: false,
            show_facts: false,
            backtest: false
          )
        end


        def add_command_options(opts)
          opts.on('-r', '--rules TYPE', %w[default custom minimal], 'Rule set to use:',
                  '  default, custom, minimal') do |rules|
            @options[:rules] = rules
          end

          add_display_flags(opts)

          opts.on('-b', '--backtest', 'Run backtest with strategy') do
            @options[:backtest] = true
          end
        end


        def add_display_flags(opts)
          opts.on('--show-rules', 'Display loaded rules') do
            @options[:show_rules] = true
          end

          opts.on('--show-facts', 'Display asserted facts') do
            @options[:show_facts] = true
          end
        end


        def banner
          KBS_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Knowledge-Based Strategy (RETE) for #{@options[:ticker]}"

          strategy = build_strategy
          maybe_print_rules(strategy)

          vector = build_data_vector(stock)

          print_section 'Executing Strategy'
          signal = strategy.execute(vector)
          puts "\nGenerated Signal: #{signal.to_s.upcase}"

          maybe_print_facts(strategy)
          maybe_run_backtest(stock, strategy)
        end

        private

        def build_strategy
          case @options[:rules]
          when 'custom'
            create_custom_strategy
          when 'minimal'
            create_minimal_strategy
          else
            SQA::Strategy::KBS.new(load_defaults: true)
          end
        end


        def maybe_print_rules(strategy)
          return unless @options[:show_rules]

          print_section 'Loaded Rules'
          strategy.print_rules
        end


        def maybe_print_facts(strategy)
          return unless @options[:show_facts]

          puts "\nAsserted Facts:"
          strategy.print_facts
        end


        def maybe_run_backtest(stock, strategy)
          return unless @options[:backtest]

          print_section 'Backtesting KBS Strategy'

          backtest = SQA::Backtest.new(
            stock: stock,
            strategy: strategy,
            initial_capital: 10_000.0,
            commission: 1.0
          )

          results = backtest.run
          print_results(results)
        end
      end
    end
  end
end
