# frozen_string_literal: true

# Load the SQA gem first (the actual financial analysis library)
require 'sqa'

# Then load CLI components
require_relative "sqa/cli/version"
require_relative "sqa/cli/dispatcher"
require_relative "sqa/cli/commands/base"

module SQA
  module CLI
    module Commands
    end
  end
end
