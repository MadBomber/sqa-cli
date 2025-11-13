# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Indicators command - Display all available TA-Lib indicators
      class Indicators < Base
        private

        def default_options
          super.merge(
            grouped: false
          )
        end

        def add_command_options(opts)
          opts.on('-g', '--grouped', 'Group indicators by category') do
            @options[:grouped] = true
          end
        end

        def banner
          <<~BANNER
            Usage: sqa-cli indicators [options]

            Display all available TA-Lib indicators from the sqa-tai gem.

            Options:
          BANNER
        end

        public

        def execute
          print_header "Available TA-Lib Indicators"

          indicators = get_available_indicators

          if @options[:grouped]
            display_grouped_indicators(indicators)
          else
            display_flat_list(indicators)
          end
        end

        private

        def get_available_indicators
          # Get all SQAI methods that are likely indicators
          # Exclude Ruby built-in methods and helper methods
          exclude_methods = [
            :alias_method, :ancestors, :attr, :attr_accessor, :attr_reader, :attr_writer,
            :autoload, :autoload?, :available?, :check_available!,
            :class, :class_eval, :class_exec, :class_variable_defined?, :class_variable_get,
            :class_variable_set, :class_variables, :clone, :const_defined?, :const_get,
            :const_missing, :const_set, :constants, :define_method, :define_singleton_method,
            :deprecate_constant, :dup, :enum_for, :eql?, :equal?, :extend, :freeze,
            :frozen?, :hash, :include, :include?, :included_modules, :inspect, :instance_eval,
            :instance_exec, :instance_method, :instance_methods, :instance_of?, :instance_variable_defined?,
            :instance_variable_get, :instance_variable_set, :instance_variables, :is_a?, :itself,
            :kind_of?, :method, :method_defined?, :methods, :module_eval, :module_exec, :name,
            :new, :nil?, :object_id, :prepend, :private_class_method, :private_constant,
            :private_instance_methods, :private_method_defined?, :private_methods, :protected_instance_methods,
            :protected_method_defined?, :protected_methods, :public_class_method, :public_constant,
            :public_instance_method, :public_instance_methods, :public_method, :public_method_defined?,
            :public_methods, :public_send, :remove_class_variable, :remove_instance_variable,
            :remove_method, :respond_to?, :send, :singleton_class, :singleton_method, :singleton_methods,
            :taint, :tainted?, :tap, :then, :to_enum, :to_s, :trust, :untaint, :untrust, :untrusted?,
            :yield_self, :__id__, :__send__, :ai, :amazing_print, :awesome_inspect
          ]

          SQAI.methods(false).reject { |m| exclude_methods.include?(m) }.sort
        end

        def display_flat_list(indicators)
          puts "\nTotal: #{indicators.size} indicators\n\n"

          # Display in columns
          indicators.map(&:to_s).each_slice(6).each do |slice|
            puts "  #{slice.join(', ')}"
          end

          puts "\nUse 'sqa-cli indicators --grouped' to see indicators organized by category."
        end

        def display_grouped_indicators(indicators)
          groups = categorize_indicators(indicators)

          puts "\nTotal: #{indicators.size} indicators\n"

          groups.each do |category, items|
            print_section category
            items.each_slice(6).each do |slice|
              puts "  #{slice.join(', ')}"
            end
            puts
          end
        end

        def categorize_indicators(indicators)
          {
            'Overlap Studies (Moving Averages & Bands)' => indicators.select { |i|
              %w[sma ema wma dema tema trima kama mama t3 ma mavp bbands].include?(i.to_s)
            },
            'Momentum Indicators' => indicators.select { |i|
              %w[adx adxr apo aroon aroonosc bop cci cmo dx macd macdext macdfix mfi minus_di minus_dm mom plus_di plus_dm ppo roc rocp rocr rocr100 rsi stoch stochf stochrsi trix ultosc willr].include?(i.to_s)
            },
            'Volume Indicators' => indicators.select { |i|
              %w[ad adosc obv].include?(i.to_s)
            },
            'Volatility Indicators' => indicators.select { |i|
              %w[atr natr trange].include?(i.to_s)
            },
            'Price Transform' => indicators.select { |i|
              %w[avgprice medprice typprice wclprice].include?(i.to_s)
            },
            'Cycle Indicators' => indicators.select { |i|
              i.to_s.start_with?('ht_')
            },
            'Pattern Recognition (Candlestick)' => indicators.select { |i|
              i.to_s.start_with?('cdl_')
            },
            'Statistic Functions' => indicators.select { |i|
              %w[beta correl linearreg linearreg_angle linearreg_intercept linearreg_slope stddev tsf var].include?(i.to_s)
            },
            'Math Transform' => indicators.select { |i|
              %w[accbands acos asin atan ceil cos cosh exp floor ln log10 sin sinh sqrt tan tanh sar sarext].include?(i.to_s)
            },
            'Other' => indicators.select { |i|
              %w[imi midpoint midprice].include?(i.to_s)
            }
          }.reject { |_, items| items.empty? }
        end
      end
    end
  end
end
