# Installation

## Prerequisites

- Ruby 3.2 or later
- Bundler gem
- Git

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/madbomber/sqa-cli.git
cd sqa-cli
```

### 2. Install Dependencies

Install the required Ruby gems:

```bash
bundle install
```

### 3. Install SQA Gem Dependencies

The SQA gem needs its dependencies installed:

```bash
cd ../sqa/main && bundle install && cd -
```

### 4. Make Executable

Ensure the CLI is executable:

```bash
chmod +x bin/sqa-cli
```

### 5. Verify Installation

Check that everything is working:

```bash
# Show version
bundle exec ./bin/sqa-cli version

# Run tests
bundle exec rake test
```

You should see:
```
sqa-cli version 0.1.0
```

And all tests should pass:
```
8 tests, 21 assertions, 0 failures
```

## Optional: Add to PATH

To use `sqa-cli` from anywhere, add the bin directory to your PATH:

```bash
# Add to ~/.bashrc or ~/.zshrc
export PATH="/path/to/sqa-cli/bin:$PATH"
```

Then you can run:
```bash
sqa-cli version
```

## Troubleshooting

### Missing Gems

If you see errors about missing gems, make sure both projects have their dependencies installed:

```bash
# In sqa-cli directory
bundle install

# In SQA gem directory
cd ../sqa/main
bundle install
```

### Permission Denied

If you see "Permission denied" when running the CLI:

```bash
chmod +x bin/sqa-cli
```

### Ruby Version Issues

Check your Ruby version:

```bash
ruby -v
```

If it's below 3.2, consider using a Ruby version manager like rbenv or rvm to install a newer version.

## Next Steps

- Read the [Quick Start Guide](quickstart.md) to begin using SQA CLI
- Check out [Usage Examples](usage.md) for detailed command examples
- Review [Sample Data](data.md) to understand the test data available
