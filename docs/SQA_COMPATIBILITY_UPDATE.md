# SQA Compatibility Update Plan for sqa-cli

**Created:** 2025-11-23
**Status:** Pending
**Priority:** Required before SQA v1.0 release
**Estimated Effort:** 30 minutes

---

## Background

The SQA gem is undergoing improvements that include adding a deprecation warning for auto-initialization at require time. In a future major release (v1.0), the auto-initialization will be removed entirely.

Currently, sqa-cli relies on SQA's auto-initialization and does not explicitly call `SQA.init`. This must be fixed to ensure forward compatibility.

---

## Current State Analysis

### How sqa-cli Loads SQA

**File:** `lib/sqa-cli.rb` (Line 4)
```ruby
require 'sqa'
# No SQA.init call - relies on auto-initialization
```

### Explicit Init Found (Partial)

**File:** `lib/sqa/cli/commands/optimize.rb` (Line 73)
```ruby
SQA.init unless defined?(SQA::Stock)
```

Only the `optimize` command has a defensive init check. All other commands assume SQA is already initialized.

---

## Required Changes

### Task 1: Add Explicit `SQA.init` Call

**File:** `lib/sqa-cli.rb`

```ruby
# frozen_string_literal: true

# Load the SQA gem first (the actual financial analysis library)
require 'sqa'

# Initialize SQA explicitly (required for SQA v1.0+)
SQA.init

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
```

**Change:** Add `SQA.init` after `require 'sqa'`

---

### Task 2: Remove Redundant Init in optimize.rb (Optional)

**File:** `lib/sqa/cli/commands/optimize.rb` (Lines 72-73)

```ruby
# FROM:
require 'sqa' unless defined?(SQA)
SQA.init unless defined?(SQA::Stock)

# TO:
# Remove these lines - initialization now happens in sqa-cli.rb
```

**Note:** This is optional cleanup. The defensive check is harmless but no longer necessary.

---

### Task 3: Update Gemspec Dependency (When SQA v1.0 Releases)

**File:** `sqa-cli.gemspec` (Line 40)

```ruby
# Current:
spec.add_dependency "sqa", "~> 0.0.33"

# After SQA v1.0 releases:
spec.add_dependency "sqa", ">= 0.0.34", "< 2.0"
```

---

## Testing

### Before Changes
```bash
cd /path/to/sqa-cli
bundle exec rake test
```

### After Changes
```bash
# Run tests
bundle exec rake test

# Manual smoke test
bundle exec sqa-cli show -t AAPL
bundle exec sqa-cli backtest -t AAPL -s RSI
bundle exec sqa-cli analyze -t AAPL
```

### With Updated SQA (Integration Test)
```bash
# Point to local SQA gem
cd /path/to/sqa
rake install

# Test sqa-cli with updated SQA
cd /path/to/sqa-cli
bundle exec sqa-cli show -t AAPL
```

---

## Timeline

| Milestone | Action |
|-----------|--------|
| **Now** | Implement Task 1 (add `SQA.init`) |
| **Before SQA v0.0.35** | Release sqa-cli with explicit init |
| **SQA v0.0.35** | Deprecation warning appears (harmless) |
| **SQA v1.0** | Auto-init removed; sqa-cli already compatible |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Double initialization | Low | None | `SQA.init` is idempotent |
| Test failures | Low | Medium | Run full test suite |
| Breaking existing users | None | None | Change is additive |

---

## Files Modified

| File | Change |
|------|--------|
| `lib/sqa-cli.rb` | Add `SQA.init` call |
| `lib/sqa/cli/commands/optimize.rb` | (Optional) Remove redundant init |
| `sqa-cli.gemspec` | (Future) Update version constraint |

---

## Commit Message Template

```
feat: Add explicit SQA.init for forward compatibility

SQA gem will remove auto-initialization at require time in v1.0.
This change adds explicit SQA.init call to ensure sqa-cli continues
to work with future SQA versions.

- Add SQA.init in lib/sqa-cli.rb after require 'sqa'
- Remove redundant init check in optimize.rb (optional)

Refs: SQA IMPROVEMENT_PLAN.md Task 3.1
```

---

## Approval

- [ ] Review changes
- [ ] Run test suite
- [ ] Manual smoke test
- [ ] Ready to implement
