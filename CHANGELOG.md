# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.2] 2025-11-12
### Added
- New `show` command to display stock price data with technical indicators in ASCII table format
  - Supports any TA-Lib technical indicator dynamically via sqa-tai gem
  - Displays timestamp, price, dollar change, percentage change, and indicator values
  - Customizable timeframe (default: 30 days)
  - Multiple indicators can be specified via comma-separated list
  - CSV export functionality with `--csv FILE` option
  - Clean numeric output with properly aligned decimals (2 decimal places for display, 3 for CSV)
  - CSV output uses `adj_close_price` as column header for clarity
- New `indicators` command to list all available TA-Lib technical indicators
  - Lists 134+ available indicators from the sqa-tai gem
  - Default view shows flat list in 6 columns
  - Grouped view (`--grouped`) organizes indicators by category (Overlap Studies, Momentum, Volume, Volatility, etc.)
  - Dynamically fetched from SQAI module for automatic updates
- MkDocs documentation website with comprehensive guides
- GitHub Actions workflow for automatic documentation deployment

### Changed
- Enhanced `analyze` command to show timestamps alongside index references in FPOP analysis output
- Updated command help text to reference `indicators` command for listing available indicators
- Added `tty-table` gem dependency for ASCII table rendering

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
[0.0.1]: https://github.com/madbomber/sqa-cli/releases/tag/v0.1.0
