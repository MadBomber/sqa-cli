# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'
require 'sqa/cli/finviz_client'

module SQA
  module CLI
    class FinvizClientTest < Minitest::Test
      def setup
        @client = FinvizClient.new
      end

      def test_gainers_parses_rows_from_finviz_html
        stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

        rows = @client.gainers

        assert_equal 3, rows.size
        assert_equal(
          { rank: 1, ticker: 'LHSW', company: 'Lianhe Sowell International Group Ltd',
            sector: 'Technology', industry: 'Software - Infrastructure', country: 'China',
            market_cap: '23.38M', pe: '18.13', price: 6.80, change_percent: 277.78,
            volume: 101_008_525 },
          rows.first
        )
      end

      def test_gainers_respects_limit
        stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

        rows = @client.gainers(limit: 1)

        assert_equal 1, rows.size
      end

      def test_gainers_keeps_non_numeric_pe_as_string
        stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

        rows = @client.gainers

        assert_equal '-', rows[1][:pe]
      end

      def test_losers_parses_rows_from_finviz_html
        stub_finviz_request('ta_toplosers', fixture('finviz_losers.html'))

        rows = @client.losers

        assert_equal 3, rows.size
        assert_equal 'MVO', rows.first[:ticker]
        assert_equal(-52.60, rows.first[:change_percent])
      end

      def test_raises_finviz_client_error_on_http_failure
        stub_request(:get, 'https://finviz.com/screener')
          .with(query: hash_including('s' => 'ta_topgainers'))
          .to_return(status: 503, body: '')

        assert_raises(FinvizClient::Error) { @client.gainers }
      end

      private

      def stub_finviz_request(signal, body)
        stub_request(:get, 'https://finviz.com/screener')
          .with(query: hash_including('v' => '111', 's' => signal))
          .to_return(status: 200, body: body)
      end

      def fixture(name)
        File.read(File.join(__dir__, '..', '..', 'fixtures', name))
      end
    end
  end
end
