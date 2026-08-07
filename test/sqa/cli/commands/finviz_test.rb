# frozen_string_literal: true

require 'test_helper'
require 'webmock/minitest'
require 'sqa/cli/commands/finviz'
require 'tmpdir'

module SQA
  module CLI
    module Commands
      class FinvizTest < Minitest::Test
        def test_execute_prints_gainers_table_by_default
          stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

          output = capture_io { Finviz.new([]).execute }.join

          assert_match(/Top 20 Gainers/, output)
          assert_match(/LHSW/, output)
        end

        def test_execute_prints_losers_table_with_flag
          stub_finviz_request('ta_toplosers', fixture('finviz_losers.html'))

          output = capture_io { Finviz.new(['--losers']).execute }.join

          assert_match(/Top 20 Losers/, output)
          assert_match(/MVO/, output)
        end

        def test_execute_respects_limit_option
          stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

          output = capture_io { Finviz.new(['--limit', '1']).execute }.join

          assert_match(/LHSW/, output)
          refute_match(/FXHO/, output)
        end

        def test_execute_writes_csv_when_requested
          stub_finviz_request('ta_topgainers', fixture('finviz_gainers.html'))

          Dir.mktmpdir do |dir|
            csv_path = File.join(dir, 'gainers.csv')

            capture_io { Finviz.new(['--csv', csv_path]).execute }

            csv_content = File.read(csv_path)
            assert_match(/LHSW/, csv_content)
            assert_match(/rank,ticker,company/, csv_content)
          end
        end

        private

        def stub_finviz_request(signal, body)
          stub_request(:get, 'https://finviz.com/screener')
            .with(query: hash_including('v' => '111', 's' => signal))
            .to_return(status: 200, body: body)
        end

        def fixture(name)
          File.read(File.join(__dir__, '..', '..', '..', 'fixtures', name))
        end
      end
    end
  end
end
