# Analyze Command

The `analyze` command runs various analysis methods on stock data to identify trading opportunities, market conditions, and seasonal patterns.

## Synopsis

```bash
sqa-cli analyze [OPTIONS]
```

## Description

The analyze command provides three powerful analysis methods:

- **FPOP** - Future Period of Performance analysis to identify inflection points
- **Regime** - Market regime detection (bull, bear, or sideways markets)
- **Seasonal** - Seasonal pattern analysis to find best/worst trading months

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `-t, --ticker SYMBOL` | String | AAPL | Stock ticker symbol to analyze |
| `-m, --methods METHODS` | String | (required) | Comma-separated list of analysis methods |
| `--fpop-periods DAYS` | Integer | 10 | Number of days for FPOP analysis |
| `--regime-window DAYS` | Integer | 60 | Moving window size for regime detection |
| `-v, --verbose` | Boolean | false | Show detailed output |
| `-h, --help` | Boolean | false | Show help message |

## Analysis Methods

### FPOP (Future Period of Performance)

Identifies potential buy and sell opportunities based on future price performance.

**How it works:**
1. Calculates future returns for each day
2. Identifies inflection points (local minima/maxima)
3. Highlights potential entry/exit points

**Use cases:**
- Finding optimal entry points
- Identifying sell signals
- Backtesting strategy development

**Example output:**
```
FPOP Analysis (10-day periods):
  Found 15 inflection points
  Buy opportunities: 8
  Sell opportunities: 7
  Average gain potential: 5.2%
```

### Regime Detection

Determines the current market regime to adjust trading strategy.

**Market Regimes:**
- **Bull Market:** Sustained upward trend
- **Bear Market:** Sustained downward trend
- **Sideways:** Range-bound, no clear trend

**How it works:**
1. Calculates moving averages over specified window
2. Analyzes price momentum and volatility
3. Classifies current regime

**Use cases:**
- Strategy selection (trend-following vs. mean-reversion)
- Risk management
- Position sizing

**Example output:**
```
Market Regime Analysis:
  Current Regime: BULL
  Confidence: 87%
  Duration: 45 days
  Trend Strength: Strong
```

### Seasonal Analysis

Analyzes historical patterns to find seasonally strong/weak months.

**How it works:**
1. Groups returns by month across all years
2. Calculates average monthly performance
3. Identifies best and worst months

**Use cases:**
- Timing entries/exits
- Portfolio rebalancing
- Calendar-based strategies

**Example output:**
```
Seasonal Pattern Analysis:
  Best Month: November (avg return: +3.2%)
  Worst Month: September (avg return: -1.8%)

  Monthly Returns:
    Jan: +1.2%
    Feb: +0.8%
    Mar: +1.5%
    ...
```

## Examples

### Run All Analyses

```bash
sqa-cli analyze --ticker AAPL --methods all
```

Runs FPOP, regime detection, and seasonal analysis on AAPL.

### Run Specific Methods

```bash
sqa-cli analyze --ticker MSFT --methods fpop,regime
```

Runs only FPOP and regime detection on MSFT.

### Single Method Analysis

```bash
sqa-cli analyze --ticker GOOGL --methods seasonal
```

Runs only seasonal analysis on GOOGL.

### Custom FPOP Periods

```bash
sqa-cli analyze --ticker TSLA --methods fpop --fpop-periods 15
```

Uses 15-day periods instead of default 10 days for FPOP analysis.

### Custom Regime Window

```bash
sqa-cli analyze --ticker AAPL --methods regime --regime-window 90
```

Uses 90-day moving window for regime detection (default is 60).

### Verbose Output

```bash
sqa-cli analyze --ticker AAPL --methods all --verbose
```

Shows detailed processing information and intermediate results.

## Common Workflows

### Initial Stock Evaluation

When first evaluating a stock:

```bash
# Get comprehensive analysis
sqa-cli analyze --ticker AAPL --methods all --verbose

# Review all three perspectives:
# 1. FPOP for entry/exit points
# 2. Regime for current market condition
# 3. Seasonal for timing considerations
```

### Strategy Development

When developing a trading strategy:

```bash
# Identify inflection points
sqa-cli analyze --ticker AAPL --methods fpop --fpop-periods 10

# Then use pattern discovery to find rules
sqa-cli pattern --ticker AAPL --min-gain 10
```

### Market Timing

For timing entries:

```bash
# Check current regime
sqa-cli analyze --ticker AAPL --methods regime

# Check if current month is favorable
sqa-cli analyze --ticker AAPL --methods seasonal
```

## Tips and Best Practices

### FPOP Analysis

- **Short periods (5-10 days):** Better for day trading and swing trading
- **Medium periods (10-20 days):** Good for position trading
- **Long periods (20+ days):** Suitable for long-term investing

### Regime Detection

- **Shorter windows (30-60 days):** More sensitive to recent changes
- **Longer windows (60-120 days):** More stable, fewer false signals
- **Very long windows (120+ days):** Captures major market cycles

### Seasonal Analysis

- Requires at least 2-3 years of data for reliability
- More reliable for large-cap stocks with consistent patterns
- Consider combining with fundamental analysis
- Don't rely solely on seasonal patterns

## Output Interpretation

### FPOP Results

- **Inflection Points:** Days where future returns change direction
- **Buy Opportunities:** Points where prices are likely to rise
- **Sell Opportunities:** Points where prices are likely to fall
- **Gain Potential:** Average expected gain from identified opportunities

### Regime Results

- **Current Regime:** Bull, Bear, or Sideways
- **Confidence:** How certain the classification is (0-100%)
- **Duration:** How long the regime has persisted
- **Trend Strength:** Weak, Moderate, or Strong

### Seasonal Results

- **Best/Worst Months:** Historically strongest/weakest performance
- **Monthly Averages:** Mean return for each month
- **Consistency:** How reliable the pattern is

## Limitations

- **Past performance doesn't guarantee future results**
- **Small sample sizes** can lead to unreliable patterns
- **Market conditions change** - historical patterns may not repeat
- **Sample data** in this project is synthetic - use real data for actual trading

## Related Commands

- [backtest](backtest.md) - Test strategies based on analysis results
- [pattern](pattern.md) - Discover trading patterns around inflection points
- [genetic](genetic.md) - Optimize strategy parameters

## See Also

- [CLI Reference](../cli-reference.md) - All command options
- [Usage Examples](../usage.md) - More examples and workflows
- [Data Guide](../data.md) - Understanding the sample data
