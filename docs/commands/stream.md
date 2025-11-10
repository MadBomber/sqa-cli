# Stream Simulation Command

Simulate real-time price streaming with strategy execution.

## Synopsis

```bash
sqa-cli stream [OPTIONS]
```

## Description

The stream command simulates real-time market data streaming, allowing you to test how strategies perform with live-like data updates.

## Quick Start

```bash
# Stream with RSI strategy
sqa-cli stream --ticker AAPL --strategies RSI

# Multiple strategies
sqa-cli stream --ticker AAPL --strategies RSI,MACD
```

## See Also

- [CLI Reference](../cli-reference.md)
- [Backtest Command](backtest.md)
