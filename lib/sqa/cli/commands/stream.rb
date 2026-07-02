#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Prints the streaming summary/signal breakdown at the end of a run.
      # Extracted from Stream because this reporting concern only depends on
      # the collected signals, not on command options or the stream itself.
      module StreamSummaryReport
        module_function

        def print_streaming_summary(sim_prices, signals_received)
          puts "\nTotal Updates: #{sim_prices.size}"
          puts "Signals Generated: #{signals_received.size}"

          return unless signals_received.any?

          print_signal_breakdown(signals_received)
          print_last_signals(signals_received)
        end


        def print_signal_breakdown(signals_received)
          puts "\nSignal Breakdown:"
          %i[buy sell hold].each do |signal|
            count = signals_received.count { |s| s[:signal] == signal }
            puts "  #{signal.to_s.upcase}: #{count}"
          end
        end


        def print_last_signals(signals_received)
          puts "\nLast 5 Signals:"
          signals_received.last(5).each do |s|
            puts "  #{s[:signal].to_s.upcase} at $#{s[:price].round(2)}"
          end
        end
      end

      STREAM_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli stream [options]

        Simulate real-time price streaming with strategy execution.
        Uses historical data to simulate live price updates.

        Options:
      BANNER

      # Stream command - Simulate real-time price streaming
      class Stream < Base
        include StreamSummaryReport

        private

        def default_options
          super.merge(
            strategies: ['RSI'],
            window: 100,
            updates: 50
          )
        end


        def add_command_options(opts)
          opts.on('-s', '--strategies LIST', Array, 'Strategies to run (comma-separated)') do |strategies|
            @options[:strategies] = strategies
          end

          opts.on('-w', '--window SIZE', Integer, 'Rolling window size (default: 100)') do |window|
            @options[:window] = window
          end

          opts.on('-u', '--updates COUNT', Integer,
                  'Number of price updates to simulate (default: 50)') do |updates|
            @options[:updates] = updates
          end
        end


        def banner
          STREAM_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Real-Time Streaming Simulation for #{@options[:ticker]}"

          print_stream_configuration
          stream = build_stream
          signals_received = attach_signal_callback(stream)

          sim_prices, sim_volumes = simulation_series(stock)

          print_section 'Starting Stream...'
          simulate_updates(stream, sim_prices, sim_volumes)

          print_section 'Streaming Summary'
          print_streaming_summary(sim_prices, signals_received)
        end

        private

        def print_stream_configuration
          puts "\nConfiguration:"
          puts "  Strategies: #{@options[:strategies].join(', ')}"
          puts "  Window Size: #{@options[:window]}"
          puts "  Simulated Updates: #{@options[:updates]}"
        end


        def build_stream
          strategy_classes = @options[:strategies].map do |name|
            resolve_strategy(name)
          end

          SQA::Stream.new(
            ticker: @options[:ticker],
            strategies: strategy_classes,
            window_size: @options[:window]
          )
        end


        def attach_signal_callback(stream)
          signals_received = []
          stream.on_signal do |signal, data|
            signals_received << { signal: signal, price: data[:price], time: Time.now }
            puts "  => Signal: #{signal.to_s.upcase} at $#{data[:price].round(2)} (#{data[:strategy]})"
          end
          signals_received
        end


        def simulation_series(stock)
          prices = stock.df['adj_close_price'].to_a
          volumes = stock.df['volume'].to_a

          start_idx = [prices.size - @options[:updates] - @options[:window], 0].max
          [prices[start_idx..], volumes[start_idx..]]
        end


        def simulate_updates(stream, sim_prices, sim_volumes)
          sim_prices.each_with_index do |price, idx|
            volume = sim_volumes[idx] || 1_000_000
            stream.update(price: price, volume: volume, timestamp: Time.now)
            print_update_progress(price, volume, idx, sim_prices.size)
          end
        end


        def print_update_progress(price, volume, idx, total)
          return unless (idx % 10).zero? && @options[:verbose]

          puts "  Update #{idx + 1}/#{total}: Price=$#{price.round(2)}, Volume=#{volume}"
        end


        STRATEGY_CLASSES = {
          'RSI' => 'SQA::Strategy::RSI',
          'MACD' => 'SQA::Strategy::MACD',
          'KBS' => 'SQA::Strategy::KBS',
          'CONSENSUS' => 'SQA::Strategy::Consensus'
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
