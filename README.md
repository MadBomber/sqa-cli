<div align="center">
  <h1>SQA CLI - Simple Qualitative Analysis</h1>

  <p>Command-line interface for financial market analysis, backtesting, and portfolio optimization.<br/>
      Part of the <a href="https://github.com/MadBomber/sqa">SQA</a> (Simple Qualitative Analysis) ecosystem.</p>
</div>

<table>
<tr>
<td width="30%" valign="middle" align="center">
    <img src="docs/assets/images/sqa.jpg" alt="Ruby Turns Information into Knowledge" width="80%">
  <br/>
</td>
<td width="70%" valign="top">

## Features

- 🎯 **7 Analysis Commands** - Comprehensive market analysis toolkit
- ⚡ **Fast Execution** - Built on the powerful SQA gem
- 📊 **Multiple Strategies** - RSI, MACD, Bollinger Bands, and more
- 🧬 **Genetic Programming** - Evolve optimal strategy parameters
- 🔍 **Pattern Discovery** - Find profitable trading patterns
- 🧠 **Knowledge-Based Strategy** - RETE inference engine for trading rules
- 📈 **Portfolio Optimization** - Modern portfolio theory and risk management
- 🌊 **Real-Time Streaming** - Simulate live market data
- 🎨 **Clean Interface** - Intuitive command structure
- 📚 **Well Documented** - Full documentation at [madbomber.github.io/sqa-cli](https://madbomber.github.io/sqa-cli)

</td>
</tr>
</table>

## Quick Links

- 📘 **[Quick Start Guide](QUICKSTART.md)** - Get started quickly, see what works now
- 💡 **[Usage Examples](USAGE_EXAMPLES.md)** - Comprehensive command examples
- 📊 **[Project Status](STATUS.md)** - Detailed project status and next steps
- 📁 **[Sample Data](data/README.md)** - Sample data documentation

## Installation

### From RubyGems (Recommended)

Once published, install the gem:

```bash
gem install sqa-cli
```

### From Source (Development)

Clone the repository and install dependencies:

```bash
git clone https://github.com/madbomber/sqa-cli.git
cd sqa-cli
bundle install
```

### Local Development

For local development with the SQA gem:

```bash
bundle install
# The Gemfile points to the local SQA gem for development
```

## Usage

```bash
sqa-cli <command> [options]
```

### Available Commands

**Core Commands:**
- `help` - Show help message
- `version` - Show version information

**Analysis Commands:**
- `analyze` - Run various analysis methods (FPOP, regime, seasonal)
- `backtest` - Run strategy backtests on historical data
- `genetic` - Evolve strategy parameters using genetic programming
- `pattern` - Discover profitable trading patterns
- `kbs` - Knowledge-based strategy using RETE inference
- `stream` - Simulate real-time price streaming
- `optimize` - Portfolio optimization and risk management

### Examples

```bash
# Show version
sqa-cli version
sqa-cli --version
sqa-cli -v

# Show help
sqa-cli help
sqa-cli --help
sqa-cli -h

# Run stock analysis
sqa-cli analyze --ticker AAPL --methods all
sqa-cli analyze --ticker MSFT --methods fpop,regime

# Backtest strategies
sqa-cli backtest --ticker AAPL --strategy RSI
sqa-cli backtest --ticker GOOGL --compare

# Discover patterns
sqa-cli pattern --ticker AAPL --min-gain 10
sqa-cli pattern --ticker TSLA --min-gain 15 --generate

# Genetic programming
sqa-cli genetic --ticker AAPL --population 30 --generations 20

# Knowledge-based strategy
sqa-cli kbs --ticker AAPL --rules default --backtest

# Real-time streaming simulation
sqa-cli stream --ticker AAPL --strategies RSI,MACD

# Portfolio optimization
sqa-cli optimize --tickers AAPL,MSFT,GOOGL --method sharpe
```

## Development

### Running Tests

```bash
bundle exec rake test
```

Or run tests directly:

```bash
ruby -Ilib:test test/sqa/cli/version_test.rb
```

### Running Linters

```bash
bundle exec rake rubocop
```

### Auto-correct Linting Issues

```bash
bundle exec rake rubocop:autocorrect
```

### Run All Tests and Linters

```bash
bundle exec rake all
```

### Interactive Console

```bash
bundle exec rake console
```

## SQA Ecosystem

`sqa-cli` is part of the SQA project:

- **[sqa](https://github.com/MadBomber/sqa)** - Core trading strategy framework and analysis library
- **[sqa-tai](https://github.com/MadBomber/sqa-tai)** - 136 technical analysis indicators (TA-Lib wrapper)
- **[sqa-cli](https://github.com/MadBomber/sqa-cli)** - Command-line interface (this tool)

SQA provides a complete Ruby ecosystem for financial analysis:
- 📊 Technical analysis and backtesting
- 🔍 Pattern recognition and discovery
- 📈 Portfolio optimization and risk management
- 🌊 Real-time market data streaming
- 🧠 Knowledge-based trading strategies with AI integration

## Architecture

This CLI follows a command-based architecture inspired by modern CLI tools:

```
sqa-cli/
├── bin/
│   └── sqa-cli                      # Executable entry point
├── lib/
│   ├── sqa.rb                       # Main module loader
│   └── sqa/
│       └── cli/
│           ├── version.rb           # Version constant
│           ├── dispatcher.rb        # Command dispatcher
│           └── commands/
│               ├── base.rb          # Base command class
│               ├── analyze.rb       # Stock analysis
│               ├── backtest.rb      # Strategy backtesting
│               ├── genetic.rb       # Genetic programming
│               ├── pattern.rb       # Pattern discovery
│               ├── kbs.rb           # Knowledge-based strategy
│               ├── stream.rb        # Real-time streaming
│               └── optimize.rb      # Portfolio optimization
├── test/                            # Minitest tests
│   ├── test_helper.rb
│   └── sqa/
│       └── cli/
│           ├── version_test.rb
│           └── dispatcher_test.rb
├── Gemfile                          # Dependencies
├── Rakefile                         # Rake tasks
└── README.md                        # This file
```

### Key Components

- **Dispatcher**: Routes commands to their respective handlers
- **Commands::Base**: Base class for all commands with common functionality
- **DebugMe Integration**: Built-in debugging support using debug_me gem

### Adding New Commands

1. Create a command file in `lib/sqa/cli/commands/`:

```ruby
# lib/sqa/cli/commands/my_command.rb
module SQA
  module CLI
    module Commands
      class MyCommand < Base
        def execute
          print_header "My Command"
          # Your command logic here
        end

        private

        def add_command_options(opts)
          opts.on('--my-option VALUE', 'Description') do |value|
            @options[:my_option] = value
          end
        end

        def banner
          "Usage: sqa-cli my_command [options]"
        end
      end
    end
  end
end
```

2. Add the command name to `COMMANDS` array in `lib/sqa/cli/dispatcher.rb`

3. The command is now available: `sqa-cli my_command --help`

## Documentation

Full documentation available at:
- **Online**: [madbomber.github.io/sqa-cli](https://madbomber.github.io/sqa-cli)
- **Getting Started**: [QUICKSTART.md](QUICKSTART.md)
- **Examples**: [USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)
- **Architecture**: Detailed in this README

## Contributing

Bug reports and pull requests are welcome at https://github.com/MadBomber/sqa-cli.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a Pull Request

## Building and Releasing the Gem

### Build the Gem

```bash
rake build
```

This creates `pkg/sqa-cli-X.Y.Z.gem`.

### Install Locally

```bash
rake install
```

### Release to RubyGems

Ensure you're authenticated with RubyGems:

```bash
gem signin
```

Then release:

```bash
rake release
```

This will:
1. Create a git tag for the version
2. Build the gem
3. Push to rubygems.org

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).

## Acknowledgments

- [SQA](https://github.com/MadBomber/sqa) - The underlying analysis framework
- [SQA-TAI](https://github.com/MadBomber/sqa-tai) - Technical analysis indicators
- [TA-Lib](https://ta-lib.org/) - Technical analysis library

## Support

- 🐛 Issues: [GitHub Issues](https://github.com/MadBomber/sqa-cli/issues)
- 📚 Docs: [Documentation Site](https://madbomber.github.io/sqa-cli)
- 💬 Discussions: [GitHub Discussions](https://github.com/MadBomber/sqa-cli/discussions)
