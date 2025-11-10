# Backtest Command

The `backtest` command tests trading strategies against historical data to evaluate their performance and characteristics.

## Synopsis

```bash
sqa-cli backtest [OPTIONS]
```

## Description

Backtesting allows you to test how a trading strategy would have performed historically. This helps:

- Evaluate strategy effectiveness
- Compare different approaches
- Understand risk/return characteristics
- Identify strategy weaknesses
- Optimize parameters

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `-t, --ticker SYMBOL` | String | AAPL | Stock ticker symbol |
| `-s, --strategy NAME` | String | RSI | Strategy to backtest |
| `-c, --capital AMOUNT` | Float | 10000 | Initial capital |
| `--commission AMOUNT` | Float | 1.0 | Commission per trade |
| `--compare` | Boolean | false | Compare all strategies |
| `-v, --verbose` | Boolean | false | Detailed output |
| `-h, --help` | Boolean | false | Show help |

## Available Strategies

### Technical Indicator Strategies

**RSI (Relative Strength Index)**
- **Type:** Momentum oscillator
- **Signals:** Overbought (>70), Oversold (<30)
- **Best for:** Mean reversion in ranging markets

**SMA (Simple Moving Average)**
- **Type:** Trend following
- **Signals:** Price crosses above/below moving average
- **Best for:** Trending markets

**EMA (Exponential Moving Average)**
- **Type:** Trend following (more responsive than SMA)
- **Signals:** Similar to SMA but faster
- **Best for:** Faster trending markets

**MACD (Moving Average Convergence Divergence)**
- **Type:** Momentum and trend
- **Signals:** MACD line crosses signal line
- **Best for:** Identifying trend changes

**Bollinger Bands**
- **Type:** Volatility-based
- **Signals:** Price touches upper/lower bands
- **Best for:** Identifying overbought/oversold in volatile markets

**Stochastic**
- **Type:** Momentum oscillator
- **Signals:** Similar to RSI
- **Best for:** Identifying reversal points

### Custom Strategies

**Volume Breakout**
- **Type:** Volume-based
- **Signals:** High volume with price movement
- **Best for:** Breakout trading

**KBS (Knowledge-Based Strategy)**
- **Type:** Rule-based inference
- **Signals:** Multiple indicator combinations
- **Best for:** Complex decision making

**Consensus**
- **Type:** Ensemble method
- **Signals:** Agreement of multiple strategies
- **Best for:** Reducing false signals

**Random**
- **Type:** Baseline/control
- **Signals:** Random buy/sell
- **Best for:** Performance comparison

## Performance Metrics

### Total Return
Percentage gain or loss over the backtest period.

```
Total Return: 15.3%
```

### Annualized Return
Return normalized to annual basis for comparison.

```
Annualized Return: 12.8%
```

### Sharpe Ratio
Risk-adjusted return (higher is better).

```
Sharpe Ratio: 1.45
```

**Interpretation:**
- < 1.0: Poor risk-adjusted performance
- 1.0-2.0: Good performance
- > 2.0: Excellent performance

### Maximum Drawdown
Largest peak-to-trough decline (lower is better).

```
Max Drawdown: -8.2%
```

### Win Rate
Percentage of profitable trades.

```
Win Rate: 58.3%
```

### Total Trades
Number of trades executed.

```
Total Trades: 24
```

### Profit Factor
Ratio of gross profits to gross losses (>1 is profitable).

```
Profit Factor: 1.67
```

## Examples

### Basic Backtest

```bash
sqa-cli backtest --ticker AAPL --strategy RSI
```

Output:
```
======================================================================
Backtesting RSI on AAPL
======================================================================

Backtest Results:
  Total Return: 15.30%
  Annualized Return: 12.80%
  Sharpe Ratio: 1.45
  Max Drawdown: -8.20%
  Win Rate: 58.33%
  Total Trades: 24
  Profit Factor: 1.67
```

### Different Strategy

```bash
sqa-cli backtest --ticker MSFT --strategy MACD
```

### Custom Capital

```bash
sqa-cli backtest --ticker GOOGL --strategy SMA --capital 50000
```

Starts with $50,000 instead of default $10,000.

### Custom Commission

```bash
sqa-cli backtest --ticker TSLA --strategy RSI --commission 5.0
```

Uses $5 commission per trade (default is $1).

### Compare All Strategies

```bash
sqa-cli backtest --ticker AAPL --compare
```

Output:
```
======================================================================
Comparing All Strategies
======================================================================

Strategy             Return%     Sharpe  Drawdown%  WinRate%    Trades
----------------------------------------------------------------------
MACD                   18.50       1.75      -7.20     61.50        26
RSI                    15.30       1.45      -8.20     58.33        24
BollingerBands         12.80       1.32      -9.50     55.00        20
SMA                    11.20       1.15     -10.30     52.50        18
EMA                    10.50       1.08     -11.00     51.20        19
Stochastic              8.30       0.95     -12.50     48.00        25
VolumeBreakout          6.50       0.82     -15.20     45.00        15
Consensus               5.20       0.75     -13.80     50.00        22
KBS                     4.80       0.68     -14.50     47.50        21
Random                 -2.30      -0.15     -20.00     48.00        30

Best Strategy: MACD (18.50% return)
```

### Verbose Output

```bash
sqa-cli backtest --ticker AAPL --strategy RSI --verbose
```

Shows trade-by-trade details and intermediate calculations.

## Interpreting Results

### Good Strategy Characteristics

- ✅ Total Return: > 10% annually
- ✅ Sharpe Ratio: > 1.0
- ✅ Max Drawdown: < 20%
- ✅ Win Rate: > 50%
- ✅ Profit Factor: > 1.5

### Red Flags

- ❌ Negative total return
- ❌ Sharpe Ratio < 0
- ❌ Max Drawdown > 30%
- ❌ Win Rate < 40%
- ❌ Profit Factor < 1.0
- ❌ Very few trades (< 10)

## Common Workflows

### Strategy Evaluation

```bash
# 1. Backtest single strategy
sqa-cli backtest --ticker AAPL --strategy RSI

# 2. If promising, compare with others
sqa-cli backtest --ticker AAPL --compare

# 3. If best performer, optimize parameters
sqa-cli genetic --ticker AAPL
```

### Multi-Stock Analysis

```bash
# Test strategy across multiple stocks
for ticker in AAPL MSFT GOOGL TSLA; do
  echo "Testing $ticker..."
  sqa-cli backtest --ticker $ticker --strategy RSI
done
```

### Parameter Sensitivity

```bash
# Test with different capital amounts
for capital in 10000 25000 50000 100000; do
  sqa-cli backtest --ticker AAPL --strategy RSI --capital $capital
done
```

## Tips and Best Practices

### Strategy Selection

- **Trending markets:** Use SMA, EMA, MACD
- **Ranging markets:** Use RSI, Stochastic, Bollinger Bands
- **Volatile markets:** Use Bollinger Bands, Volume Breakout
- **Complex decisions:** Use KBS, Consensus

### Avoiding Overfitting

1. **Use out-of-sample testing:**
   - Train on first 70% of data
   - Test on last 30%

2. **Keep strategies simple:**
   - Fewer parameters = less overfitting
   - More rules = higher chance of curve fitting

3. **Test across multiple stocks:**
   - Strategy should work on different securities
   - Not just optimized for one ticker

### Realistic Expectations

- **Commission matters:** Small edges disappear with costs
- **Slippage:** Real execution differs from backtest
- **Market impact:** Large orders move prices
- **Past ≠ Future:** Historical performance doesn't guarantee future results

### Data Quality

- **Sufficient history:** At least 1-2 years of data
- **Survivorship bias:** Don't only test on successful stocks
- **Corporate actions:** Account for splits, dividends
- **Data errors:** Verify data integrity

## Limitations

### What Backtesting Can't Tell You

- Future market conditions
- Black swan events
- Regime changes
- Execution challenges
- Psychological factors

### Known Issues

- Sample data is synthetic - use real data for actual trading
- No slippage modeling in current version
- No market impact modeling
- Assumes instant execution at close price

## Advanced Topics

### Walk-Forward Analysis

Test strategy over rolling windows:

```bash
# Future enhancement
sqa-cli backtest --ticker AAPL --strategy RSI --walk-forward
```

### Monte Carlo Simulation

Randomize trade order to test robustness:

```bash
# Future enhancement
sqa-cli backtest --ticker AAPL --strategy RSI --monte-carlo
```

## Related Commands

- [analyze](analyze.md) - Find entry/exit points to backtest
- [genetic](genetic.md) - Optimize strategy parameters
- [pattern](pattern.md) - Discover new trading patterns
- [optimize](optimize.md) - Portfolio-level optimization

## See Also

- [CLI Reference](../cli-reference.md) - All command options
- [Usage Examples](../usage.md) - Complete workflows
- [Testing Guide](../testing.md) - Strategy validation
