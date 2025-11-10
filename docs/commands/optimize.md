# Portfolio Optimization Command

Optimize portfolio allocation across multiple stocks.

## Synopsis

```bash
sqa-cli optimize [OPTIONS]
```

## Description

The optimize command determines optimal portfolio weights using modern portfolio theory and various optimization methods.

## Quick Start

```bash
# Optimize using Sharpe ratio
sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA

# Use different optimization method
sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method variance

# Show risk metrics
sqa-cli optimize --tickers AAPL,MSFT,GOOGL,TSLA --risk-metrics
```

## See Also

- [CLI Reference](../cli-reference.md)
- [Usage Examples](../usage.md)
