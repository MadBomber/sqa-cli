# CLI Reference

Complete reference for all SQA CLI commands and options.

## Global Options

These options work with all commands:

```bash
-h, --help     Show help message
-v, --verbose  Verbose output
```

## Commands

### help

Show general help or command-specific help.

```bash
sqa-cli help
sqa-cli help [command]
```

### version

Display the SQA CLI version.

```bash
sqa-cli version
```

**Output:**
```
sqa-cli version 0.1.0
```

## Analysis Commands

### analyze

Run various analysis methods on stock data.

```bash
sqa-cli analyze [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `-m, --methods METHODS` | Analysis methods (comma-separated) | - |
| `--fpop-periods DAYS` | FPOP analysis periods | 10 |
| `--regime-window DAYS` | Regime detection window | 60 |

**Available Methods:**

- `fpop` - Future Period of Performance analysis
- `regime` - Market regime detection (bull/bear/sideways)
- `seasonal` - Seasonal pattern analysis
- `all` - Run all analyses

**Examples:**

```bash
# Run all analysis methods
sqa-cli analyze --ticker AAPL --methods all

# Run specific methods
sqa-cli analyze --ticker MSFT --methods fpop,regime

# Custom parameters
sqa-cli analyze --ticker GOOGL --methods fpop --fpop-periods 15
```

### backtest

Run strategy backtests on historical data.

```bash
sqa-cli backtest [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `-s, --strategy NAME` | Strategy to backtest | RSI |
| `-c, --capital AMOUNT` | Initial capital | 10000 |
| `--commission AMOUNT` | Commission per trade | 1.0 |
| `--compare` | Compare all strategies | false |

**Available Strategies:**

- RSI - Relative Strength Index
- SMA - Simple Moving Average
- EMA - Exponential Moving Average
- MACD - Moving Average Convergence Divergence
- BollingerBands - Bollinger Bands
- Stochastic - Stochastic Oscillator
- VolumeBreakout - Volume-based breakouts
- KBS - Knowledge-Based Strategy
- Consensus - Consensus of multiple strategies
- Random - Random trading (baseline)

**Examples:**

```bash
# Backtest RSI strategy
sqa-cli backtest --ticker AAPL --strategy RSI

# Compare all strategies
sqa-cli backtest --ticker AAPL --compare

# Custom capital and commission
sqa-cli backtest --ticker MSFT --strategy MACD --capital 50000 --commission 5.0
```

### pattern

Discover profitable trading patterns using reverse engineering.

```bash
sqa-cli pattern [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `--min-gain PERCENT` | Minimum gain percentage | 10 |
| `--min-frequency COUNT` | Minimum pattern frequency | 1 |
| `--fpop DAYS` | FPOP periods | 10 |
| `--window DAYS` | Analysis window | 3 |
| `--max-patterns COUNT` | Maximum patterns to return | 10 |
| `--generate` | Generate strategies from patterns | false |
| `--export FILE` | Export patterns to CSV file | - |

**Examples:**

```bash
# Find patterns with 10% gain
sqa-cli pattern --ticker AAPL --min-gain 10

# Generate strategies from patterns
sqa-cli pattern --ticker TSLA --min-gain 15 --generate

# Export to CSV
sqa-cli pattern --ticker MSFT --min-gain 12 --export patterns.csv
```

### genetic

Evolve strategy parameters using genetic programming.

```bash
sqa-cli genetic [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `--population SIZE` | Population size | 20 |
| `--generations COUNT` | Number of generations | 10 |
| `--mutation-rate RATE` | Mutation rate (0.0-1.0) | 0.1 |
| `--crossover-rate RATE` | Crossover rate (0.0-1.0) | 0.7 |

**Examples:**

```bash
# Default genetic programming
sqa-cli genetic --ticker AAPL

# Custom population and generations
sqa-cli genetic --ticker TSLA --population 30 --generations 20

# Adjust rates
sqa-cli genetic --ticker MSFT --mutation-rate 0.2 --crossover-rate 0.8
```

### kbs

Use knowledge-based strategy with RETE inference.

```bash
sqa-cli kbs [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `--rules RULESET` | Rule set to use | default |
| `--show-rules` | Display loaded rules | false |
| `--show-facts` | Display asserted facts | false |
| `--backtest` | Run backtest | false |

**Available Rule Sets:**

- `default` - Standard trading rules
- `custom` - Custom rule set
- `minimal` - Minimal rule set

**Examples:**

```bash
# Run with default rules
sqa-cli kbs --ticker AAPL --rules default

# Show rules and facts
sqa-cli kbs --ticker AAPL --rules default --show-rules --show-facts

# Backtest the strategy
sqa-cli kbs --ticker MSFT --rules default --backtest
```

### stream

Simulate real-time price streaming with strategy execution.

```bash
sqa-cli stream [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `-t, --ticker SYMBOL` | Stock ticker symbol | AAPL |
| `--strategies LIST` | Strategies to run (comma-separated) | RSI |
| `--window DAYS` | Initial data window | 100 |
| `--updates COUNT` | Number of updates to simulate | 50 |

**Examples:**

```bash
# Stream with RSI strategy
sqa-cli stream --ticker AAPL --strategies RSI

# Multiple strategies
sqa-cli stream --ticker TSLA --strategies RSI,MACD

# Custom window and updates
sqa-cli stream --ticker MSFT --strategies RSI --window 150 --updates 100
```

### optimize

Optimize portfolio allocation across multiple stocks.

```bash
sqa-cli optimize [options]
```

**Options:**

| Option | Description | Default |
|--------|-------------|---------|
| `--tickers LIST` | Comma-separated ticker symbols | - |
| `--method METHOD` | Optimization method | sharpe |
| `--risk-free-rate RATE` | Risk-free rate | 0.02 |
| `--risk-metrics` | Show risk metrics | false |

**Optimization Methods:**

- `sharpe` - Maximum Sharpe ratio
- `variance` - Minimum variance
- `risk_parity` - Equal risk contribution
- `efficient_frontier` - Calculate efficient frontier

**Examples:**

```bash
# Optimize using Sharpe ratio
sqa-cli optimize --tickers AAPL,MSFT,GOOGL

# Use different method
sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --method variance

# Show risk metrics
sqa-cli optimize --tickers AAPL,MSFT,GOOGL --risk-metrics
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error (invalid options, file not found, etc.) |
| 2 | Unknown command |

## Environment Variables

Currently, no environment variables are used. Configuration may be added in future versions.

## See Also

- [Usage Examples](usage.md) - Detailed examples and workflows
- [Quick Start](quickstart.md) - Get started quickly
- [Commands Guide](usage.md#stock-analysis-commands) - In-depth command documentation
