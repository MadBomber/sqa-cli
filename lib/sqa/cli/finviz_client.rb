# frozen_string_literal: true

require 'faraday'
require 'nokogiri'

module SQA
  module CLI
    # Fetches and parses Finviz's public stock screener pages (no auth/API key
    # required for the free "ta_topgainers"/"ta_toplosers" preset views).
    class FinvizClient
      Error = Class.new(StandardError)

      BASE_URL = 'https://finviz.com'

      SIGNALS = {
        gainers: 'ta_topgainers',
        losers: 'ta_toplosers'
      }.freeze

      # Finviz returns a bot-block page without a browser-like User-Agent.
      USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' \
                   '(KHTML, like Gecko) Chrome/120.0 Safari/537.36'

      def initialize(connection: Faraday.new(url: BASE_URL))
        @connection = connection
      end

      def gainers(limit: 20)
        fetch(:gainers, limit: limit)
      end

      def losers(limit: 20)
        fetch(:losers, limit: limit)
      end

      private

      def fetch(direction, limit:)
        parse_rows(get_html(SIGNALS.fetch(direction))).first(limit)
      end

      def get_html(signal)
        response = @connection.get('/screener') do |req|
          req.params['v'] = '111'
          req.params['s'] = signal
          req.headers['User-Agent'] = USER_AGENT
        end

        raise Error, "Finviz request failed: HTTP #{response.status}" unless response.success?

        response.body
      rescue Faraday::Error => e
        raise Error, "Finviz request failed: #{e.message}"
      end

      def parse_rows(html)
        Nokogiri::HTML(html).css('tr.styled-row').filter_map { |row| row_to_hash(row) }
      end

      def row_to_hash(row)
        cells = row.css('td').map { |td| td.text.strip }
        return nil if cells.size < 11

        {
          rank: cells[0].to_i,
          ticker: cells[1],
          company: cells[2],
          sector: cells[3],
          industry: cells[4],
          country: cells[5],
          market_cap: cells[6],
          pe: cells[7],
          price: cells[8].to_f,
          change_percent: cells[9].delete('%').to_f,
          volume: cells[10].delete(',').to_i
        }
      end
    end
  end
end
