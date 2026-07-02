# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
  t.warning = false
end

task default: :test

desc 'Run RuboCop'
task :rubocop do
  sh 'rubocop --format simple'
end

desc 'Run RuboCop with auto-correct'
task 'rubocop:autocorrect' do
  sh 'rubocop -A'
end

desc 'Run all tests and linters'
task all: %i[test rubocop]

def flog_warn_threshold
  20.0
end


def flog_fail_threshold
  50.0
end


def build_flogger
  require 'flog'

  flogger = Flog.new(all: true)
  flogger.flog(*Dir.glob('lib/**/*.rb'))
  flogger
end


def classify_flog_score(method, score, warnings, failures)
  return if method.end_with?('#none')

  if score > flog_fail_threshold
    failures << "#{format('%.1f', score)}: #{method}"
  elsif score > flog_warn_threshold
    warnings << "#{format('%.1f', score)}: #{method}"
  end
end


def flog_scores
  warnings = []
  failures = []

  build_flogger.each_by_score { |method, score| classify_flog_score(method, score, warnings, failures) }

  [warnings, failures]
end


def report_flog_warnings(warnings)
  return if warnings.empty?

  puts "\nFlog warnings (#{flog_warn_threshold}–#{flog_fail_threshold}) — target for future refactoring:"
  warnings.each { |v| puts "  #{v}" }
end


def report_flog_failures(failures)
  if failures.empty?
    puts "\nFlog: no methods exceed the failure threshold (>=#{flog_fail_threshold})"
  else
    puts "\nFlog failures (>=#{flog_fail_threshold}) — must be refactored:"
    failures.each { |v| puts "  #{v}" }
    abort "\nFlog quality gate failed: #{failures.size} method(s) exceed #{flog_fail_threshold}"
  end
end

desc 'Check code complexity with Flog (warn >=20, fail >=50)'
task :flog_check do
  warnings, failures = flog_scores
  report_flog_warnings(warnings)
  report_flog_failures(failures)
end

desc 'Check for structural code duplication with Flay (mass >= 50)'
task :flay_check do
  require 'flay'

  mass_threshold = 50

  flay = Flay.new(mass: mass_threshold, diff: false, verbose: false, summary: false, timeout: 60)
  flay.process(*Dir.glob('lib/**/*.rb'))
  flay.analyze

  if flay.hashes.empty?
    puts "\nFlay: no structural duplication detected (mass >= #{mass_threshold})"
  else
    puts "\nFlay found structural duplication (mass >= #{mass_threshold}):"
    flay.report
    abort "\nFlay quality gate failed: #{flay.hashes.length} pattern(s) detected"
  end
end

desc 'Check code smells with Reek (fails only on new/worsened files vs .quality/reek_baseline.txt)'
task :reek_check do
  require 'reek'
  require 'reek/configuration/app_configuration'

  # Resolve .reek.yml by walking up from cwd: a gem-level config wins,
  # otherwise the shared workspace-level one is used.
  config_file = nil
  dir = Pathname.new(Dir.pwd).expand_path
  loop do
    candidate = dir.join('.reek.yml')
    if candidate.exist?
      config_file = candidate.to_s
      break
    end
    break if dir.root?

    dir = dir.parent
  end
  config = config_file ? Reek::Configuration::AppConfiguration.from_path(Pathname.new(config_file)) : nil

  # Smell count per file (only files with at least one smell).
  current = Dir.glob('lib/**/*.rb').each_with_object({}) do |file, acc|
    count = Reek::Examiner.new(File.read(file), configuration: config).smells.size
    acc[file] = count if count.positive?
  end

  # Grandfathered smell counts from .quality/reek_baseline.txt ("count\tfile").
  baseline_path = File.join('.quality', 'reek_baseline.txt')
  baseline = {}
  if File.exist?(baseline_path)
    File.readlines(baseline_path).each do |line|
      count, file = line.strip.split("\t", 2)
      baseline[file] = count.to_i if file && !file.empty?
    end
  end

  new_files = current.reject { |file, _| baseline.key?(file) }
  worsened  = current.select { |file, count| baseline.key?(file) && count > baseline[file] }

  puts "\nReek: #{current.values.sum} warning(s) across #{current.size} file(s) " \
       "(#{baseline.values.sum} grandfathered across #{baseline.size} file(s))."

  if new_files.empty? && worsened.empty?
    puts 'Reek: no new or worsened files (quality gate passed)'
  else
    puts "\nReek quality gate failed:"
    new_files.each { |file, count| puts "  NEW      #{count.to_s.rjust(3)} warning(s): #{file}" }
    worsened.each  { |file, count| puts "  WORSENED #{baseline[file].to_s.rjust(3)} -> #{count.to_s.rjust(3)}: #{file}" }
    abort "\nReek quality gate failed: #{new_files.size + worsened.size} file(s) regressed. " \
          'Fix smells, or run `asgard reek_baseline` if intentional.'
  end
end

def print_quality_gate_banner(title)
  puts "\n#{'=' * 60}"
  puts title
  puts '=' * 60
end


def run_quality_gate(title, command)
  print_quality_gate_banner(title)
  system(command) ? :pass : :fail
end


def run_all_quality_gates
  {
    tests: run_quality_gate('Quality Gate: Tests + Coverage', 'bundle exec rake test'),
    rubocop: run_quality_gate('Quality Gate: RuboCop', 'bundle exec rubocop'),
    flog: run_quality_gate('Quality Gate: Flog Complexity', 'bundle exec rake flog_check'),
    flay: run_quality_gate('Quality Gate: Flay Duplication', 'bundle exec rake flay_check'),
    reek: run_quality_gate('Quality Gate: Reek Smells', 'bundle exec rake reek_check')
  }
end


def print_quality_summary(results)
  print_quality_gate_banner('Quality Summary')
  results.each do |gate, status|
    icon = status == :pass ? 'PASS' : 'FAIL'
    puts "  [#{icon}] #{gate}"
  end
  puts '=' * 60
end

desc 'Run all quality checks: tests (with coverage), RuboCop, Flog, Flay, and Reek'
task :quality do
  results = run_all_quality_gates
  print_quality_summary(results)

  abort "\nQuality gate failed" if results.values.any?(:fail)
  puts "\nAll quality gates passed."
end

desc 'Run console with loaded environment'
task :console do
  require_relative 'lib/sqa-cli'
  require 'irb'
  ARGV.clear
  IRB.start
end

# Gem-related tasks (provided by bundler/gem_tasks):
# rake build    - Build sqa-cli-X.Y.Z.gem into the pkg directory
# rake install  - Build and install sqa-cli-X.Y.Z.gem into system gems
# rake release  - Create tag vX.Y.Z and build and push sqa-cli-X.Y.Z.gem to rubygems.org
