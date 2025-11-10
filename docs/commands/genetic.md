# Genetic Programming Command

Evolve optimal strategy parameters using genetic algorithms.

## Synopsis

```bash
sqa-cli genetic [OPTIONS]
```

## Description

The genetic command uses evolutionary algorithms to optimize trading strategy parameters. It:

1. Creates initial population of random parameters
2. Evaluates fitness (profitability) of each
3. Selects best performers to breed
4. Applies crossover and mutation
5. Repeats for specified generations
6. Returns best-performing parameters

## Quick Start

```bash
# Default optimization
sqa-cli genetic --ticker AAPL

# Larger population for better results
sqa-cli genetic --ticker AAPL --population 30 --generations 20
```

## See Also

- [CLI Reference](../cli-reference.md)
- [Backtest Command](backtest.md)
