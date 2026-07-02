# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Prints FPOP (Future Period Loss/Profit) analysis output. Extracted from
      # Analyze because this reporting concern only depends on the stock and
      # the fpop_periods option, not on the rest of the command's state.
      module AnalyzeFpopReport
        module_function

        def analyze_fpop(stock, fpop_periods)
          puts stock.inspect

          dates = stock.df['timestamp'].to_a
          analysis = SQA::FPOP.fpl_analysis(stock.df['adj_close_price'].to_a, fpop: fpop_periods)

          puts <<~HEREDOC

            FPOP Analysis (#{fpop_periods} days ahead):

          HEREDOC

          print_fpop_recent_entries(analysis, dates)
          print_fpop_quality_opportunities(analysis, dates)
        end


        def print_fpop_recent_entries(analysis, dates)
          analysis.last(10).each_with_index do |result, idx|
            actual_idx = analysis.size - 10 + idx
            timestamp = dates[actual_idx]
            puts "Index #{actual_idx} (#{timestamp}): #{result[:interpretation]}"
            print_fpop_direction_line(result)
          end
        end


        def print_fpop_direction_line(result)
          magnitude = result[:magnitude].round(2)
          risk = result[:risk].round(2)
          puts "  Direction: #{result[:direction]}, Magnitude: #{magnitude}%, Risk: #{risk}%"
        end


        def print_fpop_quality_opportunities(analysis, dates)
          puts "\nHigh-Quality Opportunities (magnitude ≥ 5%, risk ≤ 25%):"
          quality_indices = fpop_quality_indices(analysis)

          if quality_indices.empty?
            puts '  No high-quality opportunities found'
          else
            quality_indices.last(5).each do |idx|
              puts "  Index #{idx} (#{dates[idx]}): #{analysis[idx][:interpretation]}"
            end
          end
        end


        def fpop_quality_indices(analysis)
          SQA::FPOP.filter_by_quality(
            analysis,
            min_magnitude: 5.0,
            max_risk: 25.0,
            directions: [:UP]
          )
        end
      end


      # Prints market-regime detection output. Extracted from Analyze because
      # this reporting concern only depends on the stock and the regime_window
      # option, not on the rest of the command's state.
      module AnalyzeRegimeReport
        module_function

        def analyze_regime(stock, regime_window)
          regime = SQA::MarketRegime.detect(stock, window: regime_window)
          print_current_regime(regime)
          print_regime_history(stock, regime_window)
        end


        def print_current_regime(regime)
          strength_str = numeric_or_upcased(regime[:strength]) { |v| v.round(2).to_s }
          trend_str = numeric_or_upcased(regime[:trend]) { |v| "#{v.round(2)}%" }

          puts <<~HEREDOC

            Current Market Regime:
              Type: #{regime[:type].to_s.upcase}
              Volatility: #{regime[:volatility].to_s.upcase}
              Strength: #{strength_str}
              Trend: #{trend_str}
          HEREDOC
        end


        def numeric_or_upcased(value)
          value.is_a?(Numeric) ? yield(value) : value.to_s.upcase
        end


        def print_regime_history(stock, regime_window)
          puts "\nRecent Regime Changes:"
          history = SQA::MarketRegime.detect_history(stock, window: regime_window)
          history.last(5).each do |r|
            puts "  #{r[:type].to_s.upcase.ljust(10)} - #{r[:duration]} days (ended #{r[:end_date]})"
          end
        end
      end


      # Prints seasonal-pattern analysis output. Extracted from Analyze because
      # this reporting concern only depends on the stock, not on the rest of
      # the command's state.
      module AnalyzeSeasonalReport
        module_function

        def analyze_seasonal(stock)
          seasonal = SQA::SeasonalAnalyzer.analyze(stock)

          print_seasonal_summary(seasonal)
          print_monthly_returns(seasonal)
          print_quarterly_returns(seasonal)
        end


        def print_seasonal_summary(seasonal)
          puts <<~HEREDOC

            Seasonal Performance:
              Best Months: #{seasonal[:best_months].map { |m| Date::MONTHNAMES[m] }.join(', ')}
              Worst Months: #{seasonal[:worst_months].map { |m| Date::MONTHNAMES[m] }.join(', ')}
              Best Quarters: Q#{seasonal[:best_quarters].join(', Q')}
              Worst Quarters: Q#{seasonal[:worst_quarters].join(', Q')}
              Has Seasonal Pattern: #{seasonal[:has_seasonal_pattern] ? 'YES' : 'NO'}
          HEREDOC
        end


        def print_monthly_returns(seasonal)
          puts "\nMonthly Average Returns:"
          seasonal[:monthly_returns].sort_by { |m, _| m }.each do |month, stats|
            month_name = Date::MONTHNAMES[month].ljust(10)
            puts "  #{month_name}: #{signed_percent(stats[:avg_return])}% (#{stats[:count]} samples)"
          end
        end


        def print_quarterly_returns(seasonal)
          puts "\nQuarterly Average Returns:"
          seasonal[:quarterly_returns].sort_by { |q, _| q }.each do |quarter, stats|
            puts "  Q#{quarter}: #{signed_percent(stats[:avg_return])}% (#{stats[:count]} samples)"
          end
        end


        def signed_percent(value)
          avg_return = value.round(2)
          sign = avg_return >= 0 ? '+' : ''
          "#{sign}#{avg_return}"
        end
      end

      ANALYZE_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli analyze [options]

        Analyze stocks using various methods:
          - fpop:     Future Period Loss/Profit analysis
          - regime:   Market regime detection (bull/bear/sideways)
          - seasonal: Seasonal pattern analysis
          - all:      Run all analyses

        Options:
      BANNER

      # Analyze command - Run various stock analysis methods
      class Analyze < Base
        include AnalyzeFpopReport
        include AnalyzeRegimeReport
        include AnalyzeSeasonalReport

        METHODS = %w[fpop regime seasonal all].freeze

        private

        def default_options
          super.merge(
            ticker: 'AAPL',
            methods: ['all'],
            fpop_periods: 10,
            regime_window: 60
          )
        end


        def add_command_options(opts)
          opts.on('-t', '--ticker SYMBOL', 'Stock ticker symbol (default: AAPL)') do |ticker|
            @options[:ticker] = ticker.upcase
          end

          opts.on('-m', '--methods METHODS', Array, 'Analysis methods (comma-separated):',
                  "  #{METHODS.join(', ')}") do |methods|
            @options[:methods] = methods.map(&:downcase)
          end

          add_window_options(opts)
        end


        def add_window_options(opts)
          opts.on('--fpop-periods DAYS', Integer, 'FPOP analysis periods (default: 10)') do |periods|
            @options[:fpop_periods] = periods
          end

          opts.on('--regime-window DAYS', Integer, 'Regime detection window (default: 60)') do |window|
            @options[:regime_window] = window
          end
        end


        def banner
          ANALYZE_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Analyzing #{@options[:ticker]}"

          resolved_methods.each { |method| run_analysis_method(method, stock) }
        end

        private

        def resolved_methods
          @options[:methods].include?('all') ? %w[fpop regime seasonal] : @options[:methods]
        end


        def run_analysis_method(method, stock)
          case method
          when 'fpop' then run_fpop_analysis(stock)
          when 'regime' then run_regime_analysis(stock)
          when 'seasonal' then run_seasonal_analysis(stock)
          else puts "Unknown analysis method: #{method}"
          end
        end


        def run_fpop_analysis(stock)
          print_section 'FPL (Future Period Loss/Profit) Analysis'
          analyze_fpop(stock, @options[:fpop_periods])
        end


        def run_regime_analysis(stock)
          print_section 'Market Regime Detection'
          analyze_regime(stock, @options[:regime_window])
        end


        def run_seasonal_analysis(stock)
          print_section 'Seasonal Pattern Analysis'
          analyze_seasonal(stock)
        end


      end
    end
  end
end
