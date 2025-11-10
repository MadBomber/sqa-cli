# Testing

Guide to testing the SQA CLI application.

## Test Framework

SQA CLI uses **Minitest** as its testing framework, chosen for:

- Simple, intuitive syntax
- Fast execution
- Part of Ruby standard library
- Less DSL "magic" than alternatives

## Running Tests

### Run All Tests

```bash
bundle exec rake test
```

**Expected output:**
```
# Running tests with run options --seed 29814:

........

Finished tests in 0.000414s, 19323.6711 tests/s, 50724.6366 assertions/s.

8 tests, 21 assertions, 0 failures, 0 errors, 0 skips
```

### Run Specific Test File

```bash
bundle exec ruby test/sqa/cli/version_test.rb
```

### Run with Verbose Output

```bash
bundle exec rake test TESTOPTS="--verbose"
```

## Test Structure

### Directory Layout

```
test/
├── test_helper.rb              # Test configuration
└── sqa/
    └── cli/
        ├── version_test.rb     # Version tests
        └── dispatcher_test.rb  # Dispatcher tests
```

### Test Helper

The `test_helper.rb` configures the test environment:

```ruby
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "sqa"

require "minitest/autorun"
require "minitest/reporters"

Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true, slow_count: 5)
]
```

**Features:**
- Colored output
- Slow test reporting
- Auto-discovery

## Test Coverage

### Current Coverage

**Version Module:**
- ✅ VERSION constant exists
- ✅ VERSION format (semantic versioning)

**Dispatcher:**
- ✅ No arguments shows help
- ✅ Help command works
- ✅ Version command works
- ✅ Unknown command shows error
- ✅ Returns correct exit codes

### Coverage Statistics

```
Files: 2
Tests: 8
Assertions: 21
Failures: 0
Errors: 0
Skips: 0
Coverage: ~40% (core functionality)
```

## Writing Tests

### Basic Test Structure

```ruby
require "test_helper"

class SQA::CLI::MyCommandTest < Minitest::Test
  def setup
    # Runs before each test
    @command = SQA::CLI::Commands::MyCommand.new([])
  end

  def teardown
    # Runs after each test (if needed)
  end

  def test_something_works
    # Test implementation
    assert_equal expected, actual
  end
end
```

### Example: Version Test

```ruby
class SQA::CLI::VersionTest < Minitest::Test
  def test_version_exists
    refute_nil SQA::CLI::VERSION
  end

  def test_version_format
    assert_match(/\d+\.\d+\.\d+/, SQA::CLI::VERSION)
  end
end
```

### Example: Dispatcher Test

```ruby
class SQA::CLI::DispatcherTest < Minitest::Test
  def test_run_with_no_arguments_shows_help
    output = capture_io do
      result = SQA::CLI::Dispatcher.run([])
      assert_equal 0, result
    end

    assert_match(/Usage:/, output.join)
  end

  def test_run_with_unknown_command
    output = capture_io do
      result = SQA::CLI::Dispatcher.run(['unknown'])
      assert_equal 2, result
    end

    assert_match(/Unknown command/, output.join)
  end
end
```

## Testing Helpers

### Capture Output

Minitest provides `capture_io` to test output:

```ruby
def test_output
  output = capture_io do
    puts "Hello"
  end

  assert_equal "Hello\n", output[0]  # stdout
  assert_equal "", output[1]          # stderr
end
```

### Assertions

Common Minitest assertions:

```ruby
# Equality
assert_equal expected, actual
refute_equal expected, actual

# Truthiness
assert condition
refute condition
assert_nil value
refute_nil value

# Pattern matching
assert_match /pattern/, string
refute_match /pattern/, string

# Inclusion
assert_includes collection, item
refute_includes collection, item

# Exceptions
assert_raises(ExceptionClass) { code }

# Type checking
assert_instance_of Class, object
assert_kind_of Class, object
```

## Test Categories

### Unit Tests

Test individual components in isolation:

```ruby
def test_load_stock
  command = Commands::Analyze.new(['--ticker', 'AAPL'])
  stock = command.send(:load_stock)

  assert_instance_of SQA::Stock, stock
  assert_equal 'AAPL', stock.ticker
end
```

### Integration Tests

Test components working together:

```ruby
def test_analyze_command_integration
  output = capture_io do
    result = Dispatcher.run(['analyze', '--ticker', 'AAPL', '--methods', 'regime'])
    assert_equal 0, result
  end

  assert_match(/Regime Analysis/, output.join)
end
```

### End-to-End Tests

Test complete user workflows:

```ruby
def test_full_backtest_workflow
  output = capture_io do
    # Run backtest
    result = Dispatcher.run(['backtest', '--ticker', 'AAPL', '--strategy', 'RSI'])
    assert_equal 0, result
  end

  # Verify output contains expected sections
  assert_match(/Backtest Results/, output.join)
  assert_match(/Total Return/, output.join)
  assert_match(/Sharpe Ratio/, output.join)
end
```

## Fixtures and Test Data

### Sample Data

Tests use the data in `data/` directory:

```ruby
def test_with_sample_data
  # Stock data available at data/stocks/AAPL.csv
  # Portfolio data at data/portfolios/my_portfolio.csv
end
```

### Creating Test Fixtures

For unit tests that don't need real data:

```ruby
def setup
  @test_data = {
    ticker: 'TEST',
    prices: [100, 101, 102, 103, 104]
  }
end
```

## Mocking and Stubbing

Use Minitest's built-in mocking:

```ruby
def test_with_mock
  mock_stock = Minitest::Mock.new
  mock_stock.expect(:ticker, 'AAPL')
  mock_stock.expect(:data, @test_data)

  # Use mock in test
  assert_equal 'AAPL', mock_stock.ticker

  # Verify expectations
  mock_stock.verify
end
```

## Continuous Integration

The test suite runs automatically on:

- Every commit to main branch
- Every pull request
- Manual workflow dispatch

See `.github/workflows/` for CI configuration.

## Test Performance

### Slow Tests

Tests taking >0.001s are highlighted:

```
Slowest tests:
0.000017s test_run_with_version_command
0.000009s test_version_exists
```

### Optimization Tips

1. **Avoid repeated file I/O:**
   ```ruby
   def setup
     @stock_data = File.read('data/stocks/AAPL.csv') # Once
   end
   ```

2. **Use smaller datasets:**
   ```ruby
   # Instead of full 377 days, use sample
   @sample_data = stock_data.first(10)
   ```

3. **Mock expensive operations:**
   ```ruby
   # Mock SQA gem calls if testing CLI only
   ```

## Code Coverage

To measure code coverage (future enhancement):

```bash
# Install simplecov
gem install simplecov

# Add to test_helper.rb
require 'simplecov'
SimpleCov.start

# Run tests
bundle exec rake test

# View coverage report
open coverage/index.html
```

## Test-Driven Development

Recommended TDD workflow:

1. **Write failing test:**
   ```ruby
   def test_new_feature
     assert_equal expected, actual
   end
   ```

2. **Run test** (should fail):
   ```bash
   bundle exec rake test
   ```

3. **Implement feature:**
   ```ruby
   def new_feature
     # Implementation
   end
   ```

4. **Run test** (should pass):
   ```bash
   bundle exec rake test
   ```

5. **Refactor** while keeping tests green.

## Common Testing Patterns

### Testing CLI Output

```ruby
def test_cli_output
  output = capture_io do
    CLI.run(['command', 'args'])
  end

  stdout, stderr = output
  assert_match(/Expected/, stdout)
  assert_empty stderr
end
```

### Testing Exit Codes

```ruby
def test_exit_code
  result = CLI.run(['invalid'])
  assert_equal 1, result
end
```

### Testing Option Parsing

```ruby
def test_option_parsing
  command = Command.new(['--option', 'value'])
  assert_equal 'value', command.options[:option]
end
```

## Future Testing Enhancements

Planned improvements:

1. **Integration Tests:**
   - Test each command with real data
   - Verify output formatting
   - Check error handling

2. **Performance Tests:**
   - Benchmark key operations
   - Ensure no regression
   - Profile memory usage

3. **Property-Based Testing:**
   - Generate random inputs
   - Verify invariants
   - Find edge cases

4. **Contract Tests:**
   - Verify SQA gem interface
   - Check backward compatibility
   - Ensure data formats

## Troubleshooting Tests

### Tests Fail Locally

1. **Check Ruby version:**
   ```bash
   ruby -v  # Should be 3.2+
   ```

2. **Update dependencies:**
   ```bash
   bundle install
   ```

3. **Check SQA gem:**
   ```bash
   cd ../sqa/main && bundle install
   ```

### Tests Pass Locally but Fail in CI

1. **Check for environment-specific code**
2. **Verify file paths are relative**
3. **Check for time-dependent tests**
4. **Review CI logs for details**

### Slow Tests

1. **Profile tests:**
   ```bash
   bundle exec rake test TESTOPTS="--verbose"
   ```

2. **Look for:**
   - File I/O in loops
   - Network calls
   - Large data processing

3. **Optimize or mock expensive operations**

## Resources

- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [Minitest Quick Reference](https://github.com/minitest/minitest#quick-reference)
- [Ruby Testing Handbook](https://thoughtbot.com/blog/how-we-test-rails-applications)

## See Also

- [Architecture](architecture.md) - System architecture
- [Contributing](contributing.md) - Development guide
- [CLI Reference](cli-reference.md) - Command documentation
