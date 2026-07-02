#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

module SQA
  module CLI
    module Commands
      # Builds a dynamic RSI-threshold strategy class for a given set of gene
      # values. Extracted from Genetic because strategy construction is a pure
      # function of (period, buy_threshold, sell_threshold), independent of
      # command options.
      module GeneticRsiStrategyFactory
        module_function

        def create_rsi_strategy(period:, buy_threshold:, sell_threshold:)
          factory = self

          Class.new do
            define_singleton_method(:trade) do |vector|
              factory.rsi_trade_signal(vector, period, buy_threshold, sell_threshold)
            end
          end
        end

        def rsi_trade_signal(vector, period, buy_threshold, sell_threshold)
          return :hold unless vector.respond_to?(:prices) && (vector.prices&.size&.>= period)

          current_rsi = SQAI.rsi(vector.prices, period: period).last
          rsi_signal(current_rsi, buy_threshold, sell_threshold)
        rescue StandardError
          :hold
        end

        def rsi_signal(current_rsi, buy_threshold, sell_threshold)
          if current_rsi < buy_threshold
            :buy
          elsif current_rsi > sell_threshold
            :sell
          else
            :hold
          end
        end

        def run_fitness_backtest(stock, strategy)
          backtest = SQA::Backtest.new(
            stock: stock,
            strategy: strategy,
            initial_capital: 10_000.0,
            commission: 1.0
          )

          backtest.run
        end
      end

      # Prints gene constraints and evolution progress/results. Extracted from
      # Genetic because this reporting concern is independent of building or
      # running the genetic program itself.
      module GeneticEvolutionReport
        module_function

        def print_gene_constraints(gene_ranges)
          puts "\nGene Constraints:"
          puts "  RSI Period: #{gene_ranges[:min_period]}-#{gene_ranges[:max_period]}"
          puts "  Buy Threshold: #{gene_ranges[:min_buy]}-#{gene_ranges[:max_buy]}"
          puts "  Sell Threshold: #{gene_ranges[:min_sell]}-#{gene_ranges[:max_sell]}"
        end

        def print_evolution_results(best)
          puts "\nBest Parameters Found:"
          puts "  RSI Period: #{best.genes[:period]}"
          puts "  Buy Threshold: #{best.genes[:buy_threshold]}"
          puts "  Sell Threshold: #{best.genes[:sell_threshold]}"
          puts "  Fitness (Total Return): #{best.fitness.round(2)}%"
        end

        def print_evolution_history(program)
          puts "\nEvolution History:"
          program.history.each do |gen|
            best_fitness = gen[:best_fitness].round(2)
            avg_fitness = gen[:avg_fitness].round(2)
            puts "  Gen #{gen[:generation]}: Best=#{best_fitness}%, Avg=#{avg_fitness}%"
          end
        end
      end

      GENETIC_BANNER_TEXT = <<~BANNER
        Usage: sqa-cli genetic [options]

        Evolve optimal trading strategy parameters using genetic algorithms.
        Evolves RSI strategy with period and buy/sell thresholds.

        Options:
      BANNER

      GENETIC_DEFAULT_OPTIONS = {
        population: 20,
        generations: 10,
        mutation_rate: 0.15,
        crossover_rate: 0.7,
        min_period: 7,
        max_period: 30,
        min_buy: 20,
        max_buy: 40,
        min_sell: 60,
        max_sell: 80
      }.freeze

      # Genetic command - Evolve strategy parameters with genetic programming
      class Genetic < Base
        include GeneticRsiStrategyFactory
        include GeneticEvolutionReport

        private

        def default_options
          super.merge(GENETIC_DEFAULT_OPTIONS)
        end

        def add_command_options(opts)
          opts.on('-p', '--population SIZE', Integer, 'Population size (default: 20)') do |size|
            @options[:population] = size
          end

          opts.on('-g', '--generations COUNT', Integer, 'Number of generations (default: 10)') do |count|
            @options[:generations] = count
          end

          add_rate_options(opts)
        end

        def add_rate_options(opts)
          opts.on('-m', '--mutation-rate RATE', Float, 'Mutation rate (default: 0.15)') do |rate|
            @options[:mutation_rate] = rate
          end

          opts.on('-c', '--crossover-rate RATE', Float, 'Crossover rate (default: 0.7)') do |rate|
            @options[:crossover_rate] = rate
          end
        end

        def banner
          GENETIC_BANNER_TEXT
        end

        public

        def execute
          stock = load_stock
          print_header "Genetic Programming: Evolving RSI Strategy for #{@options[:ticker]}"

          program = configured_genetic_program(stock)
          best = evolve_program(program)

          print_section 'Testing Best Strategy'
          run_best_strategy_backtest(stock, best)
        end

        private

        def configured_genetic_program(stock)
          program = build_genetic_program(stock)
          print_gene_constraints(@options)
          define_genes(program)
          define_fitness(program, stock)
          program
        end

        def evolve_program(program)
          print_section 'Starting Evolution...'
          best = program.evolve

          print_section 'Evolution Results'
          print_evolution_results(best)
          print_evolution_history(program)
          best
        end

        def build_genetic_program(stock)
          SQA::GeneticProgram.new(
            stock: stock,
            population_size: @options[:population],
            generations: @options[:generations],
            mutation_rate: @options[:mutation_rate],
            crossover_rate: @options[:crossover_rate]
          )
        end

        def define_genes(program)
          program.define_genes(
            period: (@options[:min_period]..@options[:max_period]).to_a,
            buy_threshold: (@options[:min_buy]..@options[:max_buy]).to_a,
            sell_threshold: (@options[:min_sell]..@options[:max_sell]).to_a
          )
        end

        def define_fitness(program, stock)
          program.fitness do |genes|
            evaluate_fitness(stock, genes)
          end
        end

        def evaluate_fitness(stock, genes)
          strategy = create_rsi_strategy(
            period: genes[:period],
            buy_threshold: genes[:buy_threshold],
            sell_threshold: genes[:sell_threshold]
          )

          results = run_fitness_backtest(stock, strategy)
          results.total_return
        rescue StandardError => e
          puts "  Backtest failed for #{genes}: #{e.message}" if @options[:verbose]
          -100.0
        end

        def run_best_strategy_backtest(stock, best)
          best_strategy = create_rsi_strategy(
            period: best.genes[:period],
            buy_threshold: best.genes[:buy_threshold],
            sell_threshold: best.genes[:sell_threshold]
          )

          results = run_fitness_backtest(stock, best_strategy)
          print_results(results)
        end
      end
    end
  end
end
