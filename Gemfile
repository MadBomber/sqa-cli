# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 3.0.0"

# SQA gem - Simple Qualitative Analysis for financial markets
# Point to local development version
gem "sqa", path: "../sqa/main"

gem "debug_me", github: "madbomber/debug_me"

group :development, :test do
  gem "minitest", "~> 5.20"
  gem "minitest-reporters", "~> 1.6"
  gem "rake", "~> 13.0"
end

group :development do
  gem "rubocop", "~> 1.50", require: false
  gem "rubocop-minitest", "~> 0.35", require: false
end
