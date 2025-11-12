# Contributing

Thank you for your interest in contributing to SQA CLI! This guide will help you get started.

## Getting Started

### Prerequisites

- Ruby 3.2 or later
- Git
- Bundler
- Text editor or IDE
- Basic knowledge of Ruby and command-line tools

### Development Setup

1. **Fork the repository** on GitHub

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/sqa-cli.git
   cd sqa-cli
   ```

3. **Install dependencies:**
   ```bash
   bundle install
   cd ../sqa/main && bundle install && cd -
   ```

4. **Run tests:**
   ```bash
   bundle exec rake test
   ```

5. **Create a feature branch:**
   ```bash
   git checkout -b feature/my-new-feature
   ```

## Development Workflow

### 1. Make Changes

Edit files in your feature branch:

```bash
# Edit files
vim lib/sqa/cli/commands/my_command.rb

# Test your changes
bundle exec ./bin/sqa-cli my-command --help
```

### 2. Write Tests

Add tests for new functionality:

```ruby
# test/sqa/cli/my_command_test.rb
require "test_helper"

class SQA::CLI::MyCommandTest < Minitest::Test
  def test_my_feature
    # Test implementation
  end
end
```

### 3. Run Tests

Ensure all tests pass:

```bash
bundle exec rake test
```

### 4. Commit Changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "Add new feature: describe what it does"
```

**Good commit messages:**
- ✅ "Add backtest comparison feature"
- ✅ "Fix option parsing for analyze command"
- ✅ "Update documentation for pattern discovery"

**Bad commit messages:**
- ❌ "Fix bug"
- ❌ "Updates"
- ❌ "WIP"

### 5. Push and Create Pull Request

```bash
git push origin feature/my-new-feature
```

Then create a pull request on GitHub with:
- Clear description of changes
- Why the change is needed
- How it was tested
- Any breaking changes

## Code Style

### Ruby Style Guide

Follow the [Ruby Style Guide](https://rubystyle.guide/):

- **Indentation:** 2 spaces (no tabs)
- **Line length:** 80-100 characters
- **Method names:** snake_case
- **Class names:** CamelCase
- **Constants:** SCREAMING_SNAKE_CASE

### Example

```ruby
module SQA
  module CLI
    module Commands
      # Good documentation
      class MyCommand < Base
        DEFAULT_OPTION = 'value'

        def initialize(args)
          super
          @my_var = process_args(args)
        end

        # Public method
        def execute
          result = perform_action
          display_results(result)
        end

        private

        # Private helper method
        def perform_action
          # Implementation
        end
      end
    end
  end
end
```

### Linting

Run RuboCop to check style:

```bash
bundle exec rubocop
```

Fix auto-correctable issues:

```bash
bundle exec rubocop -a
```

## Testing Guidelines

### Write Tests for Everything

- ✅ New commands
- ✅ Bug fixes
- ✅ New features
- ✅ Edge cases

### Test Structure

```ruby
class MyTest < Minitest::Test
  def setup
    # Runs before each test
  end

  def teardown
    # Runs after each test
  end

  def test_specific_behavior
    # Arrange
    input = prepare_input

    # Act
    result = perform_action(input)

    # Assert
    assert_equal expected, result
  end
end
```

### Test Coverage

Aim for >80% code coverage:
- All public methods tested
- Error conditions tested
- Edge cases covered

## Documentation

### Update Documentation

When making changes, update relevant docs:

- **README.md** - For major features
- **CLI Reference** - For command changes
- **Usage Examples** - For new workflows
- **Architecture** - For structural changes

### Documentation Style

- Use clear, simple language
- Include code examples
- Add command examples with output
- Link related documentation

### MkDocs

Documentation is built with MkDocs. Preview locally:

```bash
# Install MkDocs
pip install mkdocs mkdocs-material

# Serve locally
mkdocs serve

# Visit http://127.0.0.1:8000
```

## Adding a New Command

Complete walkthrough for adding a new command:

### 1. Create Command File

```ruby
# lib/sqa/cli/commands/mycommand.rb
module SQA
  module CLI
    module Commands
      class Mycommand < Base
        def execute
          stock = load_stock
          result = perform_analysis(stock)
          print_results(result)
        end

        private

        def default_options
          super.merge(
            my_option: 'default'
          )
        end

        def add_command_options(opts)
          opts.on('--my-option VALUE', 'My custom option') do |value|
            @options[:my_option] = value
          end
        end

        def banner
          <<~BANNER
            Usage: sqa-cli mycommand [options]

            Description of what this command does.

            Options:
          BANNER
        end

        def perform_analysis(stock)
          # Implementation
        end
      end
    end
  end
end
```

### 2. Register in Dispatcher

```ruby
# lib/sqa/cli/dispatcher.rb
COMMANDS = %w[help version analyze backtest ... mycommand]

def execute
  # ...
  when 'mycommand'
    require_relative 'commands/mycommand'
    Commands::Mycommand.new(args).execute
  # ...
end
```

### 3. Add Tests

```ruby
# test/sqa/cli/mycommand_test.rb
require "test_helper"

class SQA::CLI::MycommandTest < Minitest::Test
  def test_execute_works
    # Test implementation
  end

  def test_option_parsing
    command = SQA::CLI::Commands::Mycommand.new(['--my-option', 'value'])
    assert_equal 'value', command.options[:my_option]
  end
end
```

### 4. Add Documentation

Create `docs/commands/mycommand.md`:

```markdown
# MyCommand

Description of the command.

## Usage

\`\`\`bash
sqa-cli mycommand [options]
\`\`\`

## Options

- `--my-option VALUE` - Description

## Examples

\`\`\`bash
sqa-cli mycommand --my-option value
\`\`\`
```

Update navigation in `mkdocs.yml`.

### 5. Add Usage Examples

Update `docs/usage.md` with examples.

## Pull Request Process

### Before Submitting

- [ ] All tests pass
- [ ] Code follows style guide
- [ ] Documentation updated
- [ ] Commit messages are clear
- [ ] No merge conflicts

### Pull Request Template

```markdown
## Description
Brief description of changes

## Motivation
Why is this change needed?

## Changes
- List of changes made

## Testing
How was this tested?

## Breaking Changes
Any breaking changes?

## Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Follows code style
```

### Review Process

1. **Automated checks run** (tests, linting)
2. **Maintainer reviews** code and provides feedback
3. **Address feedback** and update PR
4. **Approval** and merge

## Reporting Bugs

### Bug Report Template

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Run command '...'
2. See error

**Expected behavior**
What should happen

**Actual behavior**
What actually happens

**Environment:**
- OS: [e.g. macOS 14.0]
- Ruby version: [e.g. 3.2.0]
- SQA CLI version: [e.g. 0.1.0]

**Additional context**
Any other relevant information
```

### Before Reporting

- [ ] Search existing issues
- [ ] Verify it's reproducible
- [ ] Include minimal example
- [ ] Provide version info

## Feature Requests

### Request Template

```markdown
**Feature Description**
Clear description of the feature

**Use Case**
Why is this needed?

**Proposed Solution**
How might this work?

**Alternatives**
Other approaches considered

**Additional Context**
Anything else relevant
```

## Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn

### Communication Channels

- **GitHub Issues:** Bug reports and feature requests
- **Pull Requests:** Code contributions
- **Discussions:** Questions and ideas

## Development Tips

### Debugging

Use the `debug_me` gem:

```ruby
require 'debug_me'
include DebugMe

def my_method
  debug_me {[ '@var' ]}
end
```

### Testing Locally

Test with sample data:

```bash
bundle exec ./bin/sqa-cli analyze --ticker AAPL --methods all
```

### Iterative Development

1. Make small, focused changes
2. Test frequently
3. Commit often
4. Push regularly
5. Get feedback early

## Release Process

For maintainers:

1. **Update version** in `lib/sqa/cli/version.rb`
2. **Update CHANGELOG.md**
3. **Run full test suite**
4. **Create git tag:** `git tag v0.2.0`
5. **Push tag:** `git push --tags`
6. **Create GitHub release**

## Resources

- [Ruby Style Guide](https://rubystyle.guide/)
- [Minitest Documentation](https://docs.seattlerb.org/minitest/)
- [MkDocs Documentation](https://www.mkdocs.org/)
- [Git Best Practices](https://git-scm.com/book/en/v2)

## Questions?

If you have questions:

1. Check the [documentation](https://madbomber.github.io/sqa-cli)
2. Search [existing issues](https://github.com/madbomber/sqa-cli/issues)
3. Create a [new issue](https://github.com/madbomber/sqa-cli/issues/new)

Thank you for contributing to SQA CLI!
