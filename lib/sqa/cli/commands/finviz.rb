# frozen_string_literal: true

require_relative 'base'
require_relative '../finviz_client'
require 'tty-table'
require 'csv'

module SQA
  module CLI
    module Commands
      # Finviz command - Display today's top gaining or losing stocks
      class Finviz < Base
        DISPLAY_HEADERS = ['Rank', 'Ticker', 'Company', 'Sector', 'Price', 'Change %', 'Volume'].freeze
        CSV_HEADERS = %w[rank ticker company sector industry country market_cap pe price change_percent
                         volume].freeze

        private

        def default_options
          super.merge(direction: :gainers, limit: 20, csv: nil)
        end

        def add_command_options(opts)
          opts.on('-g', '--gainers', 'Show top gaining stocks (default)') { @options[:direction] = :gainers }
          opts.on('-l', '--losers', 'Show top losing stocks') { @options[:direction] = :losers }
          opts.on('-n', '--limit COUNT', Integer, 'Number of stocks to show (default: 20)') do |count|
            @options[:limit] = count
          end
          opts.on('--csv FILE', 'Save results to CSV file') { |file| @options[:csv] = file }
        end

        def banner
          <<~BANNER
            Usage: sqa-cli finviz [options]

            Display today's top gaining or losing stocks, scraped from Finviz's
            free screener (https://finviz.com/screener.ashx).

            Options:
          BANNER
        end

        public

        def execute
          rows = fetch_rows

          print_header title
          render_table(rows)
          maybe_save_to_csv(rows)
        end

        private

        def fetch_rows
          client = FinvizClient.new
          losers? ? client.losers(limit: @options[:limit]) : client.gainers(limit: @options[:limit])
        rescue FinvizClient::Error => e
          puts "Error fetching data from Finviz: #{e.message}"
          exit 1
        end

        def losers?
          @options[:direction] == :losers
        end

        def title
          losers? ? "Finviz Top #{@options[:limit]} Losers" : "Finviz Top #{@options[:limit]} Gainers"
        end

        def render_table(rows)
          table = TTY::Table.new(DISPLAY_HEADERS, rows.map { |row| display_row(row) })
          puts table.render(:ascii, padding: [0, 1], width: 200)
        end

        def display_row(row)
          [
            row[:rank],
            row[:ticker],
            row[:company],
            row[:sector],
            format('%.2f', row[:price]),
            format('%+.2f', row[:change_percent]),
            row[:volume]
          ]
        end

        def maybe_save_to_csv(rows)
          csv_path = @options[:csv]
          return unless csv_path

          CSV.open(csv_path, 'w') { |csv| write_csv_rows(csv, rows) }
          puts "\nData saved to #{csv_path}"
        end

        def write_csv_rows(csv, rows)
          csv_fields = CSV_HEADERS.map(&:to_sym)
          csv << CSV_HEADERS
          rows.each { |row| csv << row.values_at(*csv_fields) }
        end
      end
    end
  end
end
