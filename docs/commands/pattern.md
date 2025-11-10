# Pattern Discovery Command

Discover profitable trading patterns through reverse engineering of historical price data.

## Synopsis

```bash
sqa-cli pattern [OPTIONS]
```

## Description

The pattern command identifies combinations of technical indicators that preceded profitable trades. It works by:

1. Finding historical inflection points using FPOP
2. Analyzing indicator values at those points
3. Discovering patterns that led to gains
4. Generating tradeable strategies from patterns

## Quick Start

```bash
# Find patterns with 10% minimum gain
sqa-cli pattern --ticker AAPL --min-gain 10

# Generate strategies from discovered patterns
sqa-cli pattern --ticker AAPL --min-gain 10 --generate

# Export to CSV
sqa-cli pattern --ticker AAPL --min-gain 10 --export patterns.csv
```

## See Also

- [CLI Reference](../cli-reference.md)
- [Usage Examples](../usage.md)
- [Backtest Command](backtest.md)
