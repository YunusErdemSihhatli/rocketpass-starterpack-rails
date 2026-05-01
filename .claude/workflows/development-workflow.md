# Development Workflow

## Overview

This workflow ensures consistent, high-quality code through TDD-first development with automated quality gates.

## Workflow Steps

### 1. PLAN (5-10 minutes)

Before writing any code:

- [ ] Understand the requirements fully
- [ ] Identify affected models, controllers, services
- [ ] Design the data model (if needed)
- [ ] Define API endpoints (if needed)
- [ ] List edge cases to handle

**Output:** Clear mental model of what to build

### 2. TDD - Test First (varies)

Write failing tests BEFORE implementation:

```bash
# Create test file
touch spec/requests/api/v1/feature_spec.rb

# Write the failing test
# Run to confirm it fails
bundle exec rspec spec/requests/api/v1/feature_spec.rb
```

**Test Order:**
1. Request specs (API behavior)
2. Model specs (validations, scopes)
3. Service specs (business logic)

**Output:** Red tests that define expected behavior

### 3. IMPLEMENT (varies)

Write minimal code to make tests pass:

```bash
# Implement in this order:
# 1. Migration (if needed)
bin/rails generate migration AddFieldToModel field:type
bin/rails db:migrate

# 2. Model
# 3. Service
# 4. Controller
# 5. Serializer
# 6. Views (if Hotwire)

# Run tests after each change
bundle exec rspec spec/requests/api/v1/feature_spec.rb
```

**Output:** Green tests

### 4. QUALITY (2-3 minutes)

Run all quality checks:

```bash
# Auto-fix style issues
bundle exec rubocop -A

# Security scan
bundle exec brakeman --no-pager

# Full test suite
bundle exec rspec

# Check coverage (should be 80%+)
open coverage/index.html
```

**Output:** All checks pass

### 5. REVIEW (5 minutes)

Self-review checklist:

- [ ] Code follows project conventions (see CLAUDE.md)
- [ ] No business logic in controllers
- [ ] Services return Result objects
- [ ] Tenant scoping is correct (if applicable)
- [ ] API documentation updated (Swagger)
- [ ] No hardcoded values
- [ ] No security vulnerabilities
- [ ] Tests cover edge cases

**Output:** Clean, reviewed code

### 6. PR & MERGE

```bash
# Stage changes
git add -A

# Commit with descriptive message
git commit -m "feat: add feature description"

# Push branch
git push -u origin feature-branch

# Create PR
gh pr create --title "Add feature" --body "Description..."
```

**Output:** PR created, CI passes, merged to main

## Quick Reference

| Phase | Duration | Command |
|-------|----------|---------|
| Plan | 5-10 min | - |
| TDD | varies | `bundle exec rspec path/to/spec.rb` |
| Implement | varies | `bin/rails generate ...` |
| Quality | 2-3 min | `bundle exec rubocop -A && bundle exec brakeman && bundle exec rspec` |
| Review | 5 min | Checklist above |
| PR | 2 min | `gh pr create` |

## Common Patterns

### Adding a New Feature

1. Write request spec for API endpoint
2. Write model spec for validations
3. Write service spec for business logic
4. Create migration + model
5. Create service
6. Create controller + serializer
7. Update Swagger docs
8. Run quality checks
9. Create PR

### Fixing a Bug

1. Write failing test that reproduces the bug
2. Fix the bug with minimal changes
3. Verify test passes
4. Run full test suite
5. Run quality checks
6. Create PR

### Adding Background Job

1. Write worker spec
2. Create worker in `app/workers/`
3. Test with `Sidekiq::Testing.inline!`
4. Run quality checks
5. Create PR
