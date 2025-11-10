# SQA CLI Usage Examples

This guide demonstrates how to use the SQA CLI with the sample data files in the `data/` directory.

## Prerequisites

```bash
# Install dependencies in this project
bundle install

# Install dependencies in the SQA gem
cd ../sqa/main && bundle install && cd -

# Make sure the executable is available
chmod +x bin/sqa-cli
```

**Note**: The SQA CLI requires the SQA gem to be properly installed with all its dependencies. The commands in this guide should be run with `bundle exec` to ensure all dependencies are available.

**Current Status**: The integration between sqa-cli and the SQA gem is still being finalized. Some commands may require additional configuration of the SQA gem's data directory and API keys.

## Basic Commands

### Show Help

```bash
# General help
bundle exec ./bin/sqa-cli help

# Command-specific help
bundle exec ./bin/sqa-cli analyze --help
bundle exec ./bin/sqa-cli backtest --help
bundle exec ./bin/sqa-cli pattern --help
```

### Check Version

```bash
bundle exec ./bin/sqa-cli version
```

## Stock Analysis Commands

### 1. Analyze Stock Data

Run various analysis methods on historical stock data:

```bash
# Run all analysis methods on AAPL
./bin/sqa-cli analyze --ticker AAPL --methods all

# Run specific analysis methods
./bin/sqa-cli analyze --ticker AAPL --methods fpop,regime
./bin/sqa-cli analyze --ticker MSFT --methods seasonal

# Analyze with custom parameters
./bin/sqa-cli analyze --ticker GOOGL --methods fpop --fpop-periods 15
./bin/sqa-cli analyze --ticker TSLA --methods regime --regime-window 90

# Verbose output
./bin/sqa-cli analyze --ticker AAPL --methods all --verbose
```

**What it does:**
- **FPOP**: Future Period of Performance analysis - identifies potential buy/sell opportunities
- **Regime**: Detects market regime (bull/bear/sideways)
- **Seasonal**: Analyzes seasonal patterns and best/worst months

### 2. Backtest Trading Strategies

Test trading strategies against historical data:

```bash
# Backtest RSI strategy on AAPL
./bin/sqa-cli backtest --ticker AAPL --strategy RSI

# Test different strategies
./bin/sqa-cli backtest --ticker MSFT --strategy SMA
./bin/sqa-cli backtest --ticker GOOGL --strategy MACD
./bin/sqa-cli backtest --ticker TSLA --strategy BollingerBands

# Compare all strategies
./bin/sqa-cli backtest --ticker AAPL --compare

# Custom capital and commission
./bin/sqa-cli backtest --ticker AAPL --strategy RSI --capital 50000 --commission 5.0

# Verbose output
./bin/sqa-cli backtest --ticker AAPL --strategy RSI --verbose
```

**Available Strategies:**
- RSI, SMA, EMA, MACD
- BollingerBands, Stochastic
- VolumeBreakout, KBS, Consensus, Random

**Output includes:**
- Total return percentage
- Sharpe ratio
- Maximum drawdown
- Win rate
- Number of trades

### 3. Discover Trading Patterns

Find profitable trading patterns using reverse engineering:

```bash
# Find patterns with minimum 10% gain
./bin/sqa-cli pattern --ticker AAPL --min-gain 10

# More aggressive pattern search
./bin/sqa-cli pattern --ticker TSLA --min-gain 15 --min-frequency 2

# Generate strategies from patterns
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --generate

# Export patterns to CSV
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --export patterns_aapl.csv

# Custom parameters
./bin/sqa-cli pattern --ticker MSFT \
  --min-gain 12 \
  --fpop 15 \
  --min-frequency 3 \
  --window 5 \
  --max-patterns 15

# Verbose output
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --verbose
```

**What it does:**
- Identifies historical inflection points
- Analyzes indicator combinations at those points
- Finds patterns that preceded profitable trades
- Can generate and backtest strategies from patterns

### 4. Genetic Programming Optimization

Evolve optimal strategy parameters using genetic algorithms:

```bash
# Evolve RSI strategy for AAPL
./bin/sqa-cli genetic --ticker AAPL

# Custom population and generations
./bin/sqa-cli genetic --ticker TSLA --population 30 --generations 20

# Adjust mutation and crossover rates
./bin/sqa-cli genetic --ticker MSFT \
  --population 25 \
  --generations 15 \
  --mutation-rate 0.2 \
  --crossover-rate 0.8

# Verbose output to see evolution progress
./bin/sqa-cli genetic --ticker AAPL --verbose
```

**What it does:**
- Evolves RSI strategy parameters (period, buy/sell thresholds)
- Shows evolution history across generations
- Tests best parameters with full backtest
- Reports optimal configuration found

### 5. Knowledge-Based Strategy (KBS)

Use rule-based inference engine for trading decisions:

```bash
# Run with default rules
./bin/sqa-cli kbs --ticker AAPL --rules default

# Show loaded rules
./bin/sqa-cli kbs --ticker AAPL --rules default --show-rules

# Show asserted facts
./bin/sqa-cli kbs --ticker AAPL --rules default --show-facts

# Backtest the KBS strategy
./bin/sqa-cli kbs --ticker AAPL --rules default --backtest

# Use custom rule sets
./bin/sqa-cli kbs --ticker MSFT --rules custom
./bin/sqa-cli kbs --ticker GOOGL --rules minimal

# Full verbose output
./bin/sqa-cli kbs --ticker AAPL --rules default --show-rules --show-facts --backtest --verbose
```

**What it does:**
- Uses RETE forward-chaining inference
- Combines multiple technical indicators
- Applies trading rules based on market conditions
- Generates buy/sell/hold signals

### 6. Real-time Streaming Simulation

Simulate real-time price streaming with strategy execution:

```bash
# Stream AAPL with RSI strategy
./bin/sqa-cli stream --ticker AAPL --strategies RSI

# Multiple strategies
./bin/sqa-cli stream --ticker TSLA --strategies RSI,MACD

# Custom window and update count
./bin/sqa-cli stream --ticker MSFT \
  --strategies RSI,MACD \
  --window 150 \
  --updates 100

# Verbose output to see updates
./bin/sqa-cli stream --ticker AAPL --strategies RSI --verbose
```

**What it does:**
- Simulates real-time price updates from historical data
- Executes strategies on each update
- Tracks generated signals
- Shows signal summary

### 7. Portfolio Optimization

Optimize portfolio allocation across multiple stocks:

```bash
# Optimize using Sharpe ratio (default)
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL

# All four stocks from our data
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA

# Use different optimization methods
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method variance
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method risk_parity
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method efficient_frontier

# Show risk metrics for each stock
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --risk-metrics

# Custom risk-free rate
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method sharpe --risk-free-rate 0.03

# Verbose output
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --risk-metrics --verbose
```

**Optimization Methods:**
- **sharpe**: Maximum Sharpe ratio
- **variance**: Minimum variance
- **risk_parity**: Equal risk contribution
- **efficient_frontier**: Calculate entire efficient frontier

## Working with Portfolio Data

### Load Portfolio from CSV

```ruby
# Ruby example
require 'csv'

portfolio = CSV.read('data/portfolios/my_portfolio.csv', headers: true)
portfolio.each do |position|
  puts "#{position['ticker']}: #{position['shares']} shares @ $#{position['purchase_price']}"
end
```

### Load Portfolio from JSON

```ruby
# Ruby example
require 'json'

portfolio = JSON.parse(File.read('data/portfolios/my_portfolio.json'))
puts "Portfolio: #{portfolio['portfolio_name']}"
puts "Total Invested: $#{portfolio['total_invested']}"

portfolio['positions'].each do |position|
  puts "#{position['ticker']}: #{position['shares']} shares (avg: $#{position['average_purchase_price']})"
end
```

### Analyze Portfolio Positions

```bash
# Analyze each stock in the portfolio
./bin/sqa-cli analyze --ticker AAPL --methods all
./bin/sqa-cli analyze --ticker MSFT --methods all
./bin/sqa-cli analyze --ticker GOOGL --methods all
./bin/sqa-cli analyze --ticker TSLA --methods all

# Optimize the portfolio allocation
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --risk-metrics
```

## Advanced Usage

### Combining Commands

```bash
# Analyze, backtest, and find patterns for AAPL
./bin/sqa-cli analyze --ticker AAPL --methods all
./bin/sqa-cli backtest --ticker AAPL --compare
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --generate

# Complete analysis workflow
./bin/sqa-cli analyze --ticker TSLA --methods all --verbose
./bin/sqa-cli genetic --ticker TSLA --population 30 --generations 20
./bin/sqa-cli backtest --ticker TSLA --strategy RSI
./bin/sqa-cli kbs --ticker TSLA --backtest
```

### Save Output to Files

```bash
# Redirect output to files
./bin/sqa-cli analyze --ticker AAPL --methods all > analysis_aapl.txt
./bin/sqa-cli backtest --ticker AAPL --compare > backtest_comparison.txt

# Export patterns
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --export data/patterns_aapl.csv
```

### Using Different Tickers

```bash
# The CLI works with any ticker that has data in data/stocks/
# Available tickers: AAPL, MSFT, GOOGL, TSLA

for ticker in AAPL MSFT GOOGL TSLA; do
  echo "Analyzing $ticker..."
  ./bin/sqa-cli analyze --ticker $ticker --methods regime
done
```

## Common Workflows

### 1. Quick Stock Analysis

```bash
# Get a quick overview of a stock
./bin/sqa-cli analyze --ticker AAPL --methods all
./bin/sqa-cli backtest --ticker AAPL --strategy RSI
```

### 2. Strategy Development

```bash
# Find patterns, evolve parameters, test strategy
./bin/sqa-cli pattern --ticker AAPL --min-gain 10 --generate
./bin/sqa-cli genetic --ticker AAPL --population 30 --generations 20
./bin/sqa-cli backtest --ticker AAPL --compare
```

### 3. Portfolio Analysis

```bash
# Analyze individual positions
for ticker in AAPL MSFT GOOGL TSLA; do
  ./bin/sqa-cli analyze --ticker $ticker --methods regime,seasonal
done

# Optimize allocation
./bin/sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --risk-metrics
```

### 4. Strategy Comparison

```bash
# Compare all strategies on multiple stocks
./bin/sqa-cli backtest --ticker AAPL --compare
./bin/sqa-cli backtest --ticker MSFT --compare
./bin/sqa-cli backtest --ticker GOOGL --compare
./bin/sqa-cli backtest --ticker TSLA --compare
```

## Tips and Best Practices

1. **Start with Analysis**: Always run `analyze` first to understand the stock's characteristics
2. **Use Verbose Mode**: Add `--verbose` to see detailed processing information
3. **Compare Strategies**: Use `--compare` in backtest to find the best strategy
4. **Iterate on Patterns**: Adjust `--min-gain` and `--min-frequency` to find optimal patterns
5. **Genetic Programming**: Use larger populations and more generations for better results
6. **Portfolio Optimization**: Include `--risk-metrics` to understand individual stock risks

## Troubleshooting

### If a command doesn't work:

1. Check that the SQA gem is properly installed:
   ```bash
   bundle install
   ```

2. Verify the ticker has data:
   ```bash
   ls data/stocks/
   ```

3. Use `--help` to see all options:
   ```bash
   ./bin/sqa-cli <command> --help
   ```

4. Enable verbose mode for debugging:
   ```bash
   ./bin/sqa-cli <command> --ticker AAPL --verbose
   ```

## Next Steps

- Explore the `data/` directory to understand the data format
- Read `data/README.md` for detailed data documentation
- Check the main `README.md` for architecture details
- Run `bundle exec rake test` to verify everything works
