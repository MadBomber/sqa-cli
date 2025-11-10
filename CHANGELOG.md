# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- MkDocs documentation website with comprehensive guides
- GitHub Actions workflow for automatic documentation deployment

## [0.1.0] - 2025-11-09

### Added
- Initial release of SQA CLI
- Core commands: help, version
- Analysis commands: analyze, backtest, pattern, genetic, kbs, stream, optimize
- FPOP (Future Period of Performance) analysis
- Market regime detection
- Seasonal pattern analysis
- Strategy backtesting with multiple strategies (RSI, MACD, Bollinger Bands, etc.)
- Pattern discovery for profitable trading patterns
- Genetic programming for strategy parameter optimization
- Knowledge-based strategy using RETE inference engine
- Real-time price streaming simulation
- Portfolio optimization and risk management
- Command-based architecture for easy extensibility
- Integration with SQA gem for financial analysis
- Debug support using debug_me gem
- Comprehensive test suite using Minitest
- Code quality checks with RuboCop

[Unreleased]: https://github.com/madbomber/sqa-cli/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/madbomber/sqa-cli/releases/tag/v0.1.0
