# frozen_string_literal: true

require_relative 'base'
require 'tty-table'
require 'csv'

module SQA
  module CLI
    module Commands
      # Stateless numeric formatting helpers for Show's table output.
      # Extracted from Show because these are pure functions of a value,
      # independent of command options or stock data.
      module ShowFormatting
        module_function

        def format_price(value)
          return '       -' if value.nil?

          format('%8.2f', value)
        end

        def format_change(value)
          return '      -' if value.nil?

          format('%+7.2f', value)
        end

        def format_percent(value)
          return '      -' if value.nil?

          format('%+7.2f', value)
        end

        def format_indicator_value(value)
          return '       -' if value.nil?

          format('%8.2f', value)
        end
      end

      # CSV export helper for Show's table data. Extracted from Show because
      # writing rows to disk is a distinct responsibility from building/rendering
      # the on-screen table.
      module ShowCsvWriter
        module_function

        def save_to_csv(headers, rows, filename)
          CSV.open(filename, 'w') do |csv|
            csv << headers
            rows.each { |row| csv << round_csv_row(row) }
          end
        end

        def round_csv_row(row)
          row.map { |value| value.is_a?(Float) ? value.round(3) : value }
        end
      end

      # Builds table headers/rows (for both on-screen display and CSV export)
      # from precomputed price/indicator data. Extracted from Show because
      # assembling rows is a distinct responsibility from orchestrating the
      # command or fetching stock/indicator data.
      module ShowTableBuilder
        module_function

        def timeframe_start_idx(stock, timeframe)
          total_rows = stock.df.data.height
          [0, total_rows - timeframe].max
        end

        def calculate_price_changes(prices)
          dollar_changes = []
          percent_changes = []

          prices.each_with_index do |price, idx|
            change = price_change_at(prices, price, idx)
            dollar_changes << change&.first
            percent_changes << change&.last
          end

          [dollar_changes, percent_changes]
        end

        def price_change_at(prices, price, idx)
          return nil if idx.zero?

          prev_price = prices[idx - 1]
          [price - prev_price, ((price - prev_price) / prev_price) * 100]
        end

        def build_table_headers(indicators)
          headers = ['timestamp', 'Price', '$Change', '%Change']
          csv_headers = ['timestamp', 'adj_close_price', '$Change', '%Change']
          indicators.each do |indicator|
            headers << indicator.upcase
            csv_headers << indicator.upcase
          end
          [headers, csv_headers]
        end

        def build_table_rows(table_data, indicators)
          rows = []
          csv_rows = []

          table_data[:timestamps].each_with_index do |timestamp, idx|
            csv_row = csv_row_for(table_data, timestamp, idx)
            display_row = display_row_for(table_data, timestamp, idx)
            append_indicator_values(table_data, indicators, csv_row, display_row, idx)

            csv_rows << csv_row
            rows << display_row
          end

          [rows, csv_rows]
        end

        def append_indicator_values(table_data, indicators, csv_row, display_row, idx)
          indicators.each do |indicator|
            value = table_data[:indicator_data][indicator][idx]
            csv_row << value
            display_row << ShowFormatting.format_indicator_value(value)
          end
        end

        def csv_row_for(table_data, timestamp, idx)
          [
            timestamp.to_s,
            table_data[:prices][idx],
            table_data[:dollar_changes][idx],
            table_data[:percent_changes][idx]
          ]
        end

        def display_row_for(table_data, timestamp, idx)
          [
            timestamp.to_s,
            ShowFormatting.format_price(table_data[:prices][idx]),
            ShowFormatting.format_change(table_data[:dollar_changes][idx]),
            ShowFormatting.format_percent(table_data[:percent_changes][idx])
          ]
        end
      end

      # Looks up and invokes a TA-Lib indicator via SQAI, normalizing its return
      # shape. Extracted from Show because indicator lookup/invocation is a
      # distinct responsibility from building the display table.
      module ShowIndicatorCalculator
        module_function

        def calculate_indicator(stock, indicator, start_idx, timeframe)
          indicator_name = indicator.downcase.to_sym

          unless SQAI.respond_to?(indicator_name)
            warn "Warning: Indicator '#{indicator}' not found in TA-Lib. Skipping."
            return Array.new(timeframe, nil)
          end

          fetch_indicator_values(stock, indicator_name, indicator, start_idx, timeframe)
        end

        def fetch_indicator_values(stock, indicator_name, indicator, start_idx, timeframe)
          closes = stock.df['adj_close_price'].to_a
          result = SQAI.send(indicator_name, closes)
          values = extract_indicator_series(result)

          values[start_idx..] || Array.new(timeframe, nil)
        rescue StandardError => e
          warn "Error calculating #{indicator}: #{e.message}"
          Array.new(timeframe, nil)
        end

        def extract_indicator_series(result)
          # Extract the result (handle both single and multiple output indicators)
          if result.is_a?(Hash)
            # For indicators that return multiple values (like MACD, BBANDS)
            # Use the first output series
            result.values.first
          elsif result.is_a?(Array)
            result
          else
            [result]
          end
        end
      end

      # Static banner text for Show's --help output. Kept outside the class
      # body so it doesn't count against Show's class-length budget.
      SHOW_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli show [options]

        Display stock price data with technical indicators in a table format.

        This command supports any TA-Lib technical indicator. Common examples:
          - Moving averages: sma, ema, dema, tema, wma
          - Momentum: rsi, macd, stoch, cci, adx
          - Volatility: bbands, atr, natr
          - And many more...

        To see all available indicators, run:
          sqa-cli indicators

        Options:
      BANNER

      # Show command - Display stock price data with indicators in a table
      class Show < Base
        include ShowFormatting
        include ShowCsvWriter
        include ShowIndicatorCalculator
        include ShowTableBuilder

        private

        def default_options
          super.merge(
            ticker: 'AAPL',
            timeframe: 30,
            indicators: [],
            csv: nil
          )
        end

        def add_command_options(opts)
          add_display_options(opts)
          add_output_options(opts)
        end

        def add_display_options(opts)
          opts.on('-t', '--ticker SYMBOL', 'Stock ticker symbol (default: AAPL)') do |ticker|
            @options[:ticker] = ticker.upcase
          end

          opts.on('-f', '--timeframe DAYS', Integer, 'Number of days to display (default: 30)') do |days|
            @options[:timeframe] = days
          end

          add_indicators_option(opts)
        end

        def add_indicators_option(opts)
          opts.on('-i', '--indicators INDICATORS', Array,
                  'Comma-separated indicators (any TA-Lib indicator):',
                  '  Examples: sma, ema, rsi, macd, bbands, stoch, adx, cci, etc.') do |indicators|
            @options[:indicators] = indicators.map(&:downcase)
          end
        end

        def add_output_options(opts)
          opts.on('--csv FILE', 'Save table data to CSV file') do |file|
            @options[:csv] = file
          end
        end

        def banner
          SHOW_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock

          print_header title_for(stock)
          print_show_subheader

          display_table(stock)
        end

        private

        def title_for(stock)
          has_name = stock.respond_to?(:name) && stock.name && !stock.name.empty?
          company_name = has_name ? stock.name : @options[:ticker]
          return @options[:ticker] if company_name == @options[:ticker]

          "#{@options[:ticker]} - #{company_name}"
        end

        def print_show_subheader
          indicators_str = if @options[:indicators].empty?
                             'No indicators'
                           else
                             @options[:indicators].map(&:upcase).join(', ')
                           end

          puts <<~HEREDOC

            Duration: Last #{@options[:timeframe]} days
            Indicators: #{indicators_str}

          HEREDOC
        end

        def display_table(stock)
          table_data = build_table_data(stock)

          headers, csv_headers = build_table_headers(@options[:indicators])
          rows, csv_rows = build_table_rows(table_data, @options[:indicators])

          maybe_save_to_csv(csv_headers, csv_rows)
          render_table(headers, rows)
        end

        def build_table_data(stock)
          start_idx = timeframe_start_idx(stock, @options[:timeframe])
          timestamps = stock.df['timestamp'].to_a[start_idx..]
          prices = stock.df['adj_close_price'].to_a[start_idx..]
          dollar_changes, percent_changes = calculate_price_changes(prices)
          indicator_data = calculate_all_indicators(stock, start_idx)

          { timestamps: timestamps, prices: prices, dollar_changes: dollar_changes,
            percent_changes: percent_changes, indicator_data: indicator_data }
        end

        def calculate_all_indicators(stock, start_idx)
          indicator_data = {}
          @options[:indicators].each do |indicator|
            indicator_data[indicator] =
              calculate_indicator(stock, indicator, start_idx, @options[:timeframe])
          end
          indicator_data
        end

        def maybe_save_to_csv(csv_headers, csv_rows)
          return unless @options[:csv]

          save_to_csv(csv_headers, csv_rows, @options[:csv])
          puts "\nData saved to #{@options[:csv]}"
        end

        def render_table(headers, rows)
          table = TTY::Table.new(headers, rows)
          puts table.render(:ascii, padding: [0, 1])
        end
      end
    end
  end
end
