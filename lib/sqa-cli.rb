# frozen_string_literal: true

# This file must be named sqa-cli.rb (not sqa_cli.rb) because it is the
# gem's entry point: spec.name is 'sqa-cli' and Bundler/RubyGems resolve
# `require 'sqa-cli'` to lib/sqa-cli.rb by exact match on the gem name.
# Renaming this file would break that require path for all consumers.
# (Naming/FileName is excluded for this path in .rubocop.yml.common.)

# Load the SQA gem first (the actual financial analysis library)
require 'sqa'

# Then load CLI components
require_relative 'sqa/cli/version'
require_relative 'sqa/cli/dispatcher'
require_relative 'sqa/cli/commands/base'

module SQA
  module CLI
    # Namespace for individual CLI subcommand classes (e.g. Show, Backtest, Analyze).
    module Commands
    end
  end
end
