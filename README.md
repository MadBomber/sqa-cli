# SQA CLI

Simple Qualitative Analysis Command Line Interface

A modular CLI for financial and stock market analysis using the SQA gem. Features include backtesting, pattern discovery, genetic programming, portfolio optimization, and real-time market analysis.

## Quick Links

- **[QUICKSTART.md](QUICKSTART.md)** - Get started quickly, see what works now
- **[USAGE_EXAMPLES.md](USAGE_EXAMPLES.md)** - Comprehensive command examples
- **[STATUS.md](STATUS.md)** - Detailed project status and next steps
- **[data/README.md](data/README.md)** - Sample data documentation

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

## About SQA

SQA (Simple Qualitative Analysis) is a Ruby gem for financial market analysis, providing tools for:
- Technical analysis and backtesting
- Pattern recognition and discovery
- Portfolio optimization
- Real-time market data streaming
- Knowledge-based trading strategies

This CLI provides a unified interface to all SQA features.

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

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
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

MIT License - see [LICENSE.txt](LICENSE.txt) for details
