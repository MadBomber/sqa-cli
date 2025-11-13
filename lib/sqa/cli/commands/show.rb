# frozen_string_literal: true

require_relative 'base'
require 'tty-table'
require 'csv'

module SQA
  module CLI
    module Commands
      # Show command - Display stock price data with indicators in a table
      class Show < Base
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
          opts.on('-t', '--ticker SYMBOL', 'Stock ticker symbol (default: AAPL)') do |ticker|
            @options[:ticker] = ticker.upcase
          end

          opts.on('-f', '--timeframe DAYS', Integer, 'Number of days to display (default: 30)') do |days|
            @options[:timeframe] = days
          end

          opts.on('-i', '--indicators INDICATORS', Array, 'Comma-separated indicators (any TA-Lib indicator):', '  Examples: sma, ema, rsi, macd, bbands, stoch, adx, cci, etc.') do |indicators|
            @options[:indicators] = indicators.map(&:downcase)
          end

          opts.on('--csv FILE', 'Save table data to CSV file') do |file|
            @options[:csv] = file
          end
        end

        def banner
          <<~BANNER
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
        end

        public

        def execute
          stock = load_stock

          # Get company name from stock object
          company_name = if stock.respond_to?(:name) && stock.name && !stock.name.empty?
                          stock.name
                        else
                          @options[:ticker]
                        end

          # Print header
          title = company_name == @options[:ticker] ? @options[:ticker] : "#{@options[:ticker]} - #{company_name}"
          print_header title

          # Print sub-header
          indicators_str = @options[:indicators].empty? ? "No indicators" : @options[:indicators].map(&:upcase).join(', ')

          puts <<~HEREDOC

            Duration: Last #{@options[:timeframe]} days
            Indicators: #{indicators_str}

          HEREDOC

          # Build and display table
          display_table(stock)
        end

        private

        def display_table(stock)
          # Get the data for the specified timeframe
          total_rows = stock.df.data.height
          start_idx = [0, total_rows - @options[:timeframe]].max

          timestamps = stock.df["timestamp"].to_a[start_idx..-1]
          prices = stock.df["adj_close_price"].to_a[start_idx..-1]

          # Calculate price changes
          dollar_changes = []
          percent_changes = []

          prices.each_with_index do |price, idx|
            if idx == 0
              dollar_changes << nil
              percent_changes << nil
            else
              prev_price = prices[idx - 1]
              dollar_change = price - prev_price
              percent_change = ((price - prev_price) / prev_price) * 100
              dollar_changes << dollar_change
              percent_changes << percent_change
            end
          end

          # Calculate indicators
          indicator_data = {}
          @options[:indicators].each do |indicator|
            indicator_data[indicator] = calculate_indicator(stock, indicator, start_idx)
          end

          # Build table headers
          headers = ['timestamp', 'Price', '$Change', '%Change']
          csv_headers = ['timestamp', 'adj_close_price', '$Change', '%Change']
          @options[:indicators].each do |indicator|
            headers << indicator.upcase
            csv_headers << indicator.upcase
          end

          # Build table rows
          rows = []
          csv_rows = []
          timestamps.each_with_index do |timestamp, idx|
            # Row for CSV (clean numeric values)
            csv_row = [
              timestamp.to_s,
              prices[idx],
              dollar_changes[idx],
              percent_changes[idx]
            ]

            # Row for display (formatted values)
            display_row = [
              timestamp.to_s,
              format_price(prices[idx]),
              format_change(dollar_changes[idx]),
              format_percent(percent_changes[idx])
            ]

            # Add indicator values
            @options[:indicators].each do |indicator|
              value = indicator_data[indicator][idx]
              csv_row << value
              display_row << format_indicator_value(value)
            end

            csv_rows << csv_row
            rows << display_row
          end

          # Save to CSV if requested
          if @options[:csv]
            save_to_csv(csv_headers, csv_rows, @options[:csv])
            puts "\nData saved to #{@options[:csv]}"
          end

          # Create and render table
          table = TTY::Table.new(headers, rows)
          puts table.render(:ascii, padding: [0, 1])
        end

        def save_to_csv(headers, rows, filename)
          CSV.open(filename, 'w') do |csv|
            csv << headers
            rows.each do |row|
              # Round all float values to 3 decimal places
              rounded_row = row.map do |value|
                if value.is_a?(Float)
                  value.round(3)
                else
                  value
                end
              end
              csv << rounded_row
            end
          end
        end

        def calculate_indicator(stock, indicator, start_idx)
          indicator_name = indicator.downcase.to_sym

          # Check if SQAI has this indicator
          unless SQAI.respond_to?(indicator_name)
            warn "Warning: Indicator '#{indicator}' not found in TA-Lib. Skipping."
            return Array.new(@options[:timeframe], nil)
          end

          # Get required data arrays
          closes = stock.df["adj_close_price"].to_a

          # Call the indicator through SQAI
          # Most indicators take close prices as first argument
          begin
            result = SQAI.send(indicator_name, closes)

            # Extract the result (handle both single and multiple output indicators)
            values = if result.is_a?(Hash)
                      # For indicators that return multiple values (like MACD, BBANDS)
                      # Use the first output series
                      result.values.first
                    elsif result.is_a?(Array)
                      result
                    else
                      [result]
                    end

            # Return only the portion we need
            values[start_idx..-1] || Array.new(@options[:timeframe], nil)
          rescue => e
            warn "Error calculating #{indicator}: #{e.message}"
            Array.new(@options[:timeframe], nil)
          end
        end

        def format_price(value)
          return '       -' if value.nil?
          sprintf('%8.2f', value)
        end

        def format_change(value)
          return '      -' if value.nil?
          sprintf('%+7.2f', value)
        end

        def format_percent(value)
          return '      -' if value.nil?
          sprintf('%+7.2f', value)
        end

        def format_indicator_value(value)
          return '       -' if value.nil?
          sprintf('%8.2f', value)
        end
      end
    end
  end
end
