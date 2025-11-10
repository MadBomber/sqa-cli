# Knowledge-Based Strategy Command

Execute rule-based trading strategies using RETE inference engine.

## Synopsis

```bash
sqa-cli kbs [OPTIONS]
```

## Description

The KBS command uses a knowledge-based system with forward-chaining inference to make trading decisions based on multiple technical indicators and market conditions.

## Quick Start

```bash
# Run with default rules
sqa-cli kbs --ticker AAPL --rules default

# Show rules and backtest
sqa-cli kbs --ticker AAPL --rules default --show-rules --backtest
```

## See Also

- [CLI Reference](../cli-reference.md)
- [Usage Examples](../usage.md)
