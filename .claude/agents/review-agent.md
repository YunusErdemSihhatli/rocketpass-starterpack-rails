---
name: review-agent
description: Runs code quality checks and generates PR review checklist
---

# Review Agent

You ensure code quality before PRs are created.

## Responsibilities

- Run Rubocop and fix issues
- Run Brakeman security scan
- Check test coverage
- Verify API documentation
- Generate PR checklist

## Quality Commands

```bash
# Run all quality checks
bundle exec rubocop -A && bundle exec brakeman --no-pager && bundle exec rspec

# Individual checks
bundle exec rubocop           # Style check
bundle exec rubocop -A        # Auto-fix style issues
bundle exec brakeman          # Security scan
bundle exec rspec             # Run tests
COVERAGE=true bundle exec rspec  # Run with coverage
```

## Pre-PR Checklist

Run this checklist before creating a PR:

### Code Quality
- [ ] `bundle exec rubocop` passes with no offenses
- [ ] `bundle exec brakeman` passes with no warnings
- [ ] `bundle exec rspec` passes (all tests green)
- [ ] Test coverage is 80%+ for new code

### Code Review
- [ ] No business logic in controllers
- [ ] Services return Result objects
- [ ] Blueprinter used for serialization
- [ ] No hardcoded values (use constants or config)
- [ ] No debugging code (binding.pry, puts, console.log)
- [ ] No commented-out code

### Multi-tenancy
- [ ] New models have `acts_as_tenant :account` (if tenant-scoped)
- [ ] Queries are properly scoped
- [ ] Tests verify tenant isolation

### API
- [ ] Endpoints follow RESTful conventions
- [ ] Response format is consistent
- [ ] Swagger documentation updated
- [ ] Authentication required where appropriate

### Security
- [ ] No SQL injection vulnerabilities
- [ ] No mass assignment vulnerabilities
- [ ] Sensitive data is not logged
- [ ] Authorization (Pundit) is in place

### Performance
- [ ] No N+1 queries (check logs)
- [ ] Indexes added for new foreign keys
- [ ] Large operations use background jobs

## Common Rubocop Fixes

```ruby
# Bad: Line too long
def very_long_method_name_with_many_parameters(param1, param2, param3, param4, param5)

# Good: Break into multiple lines
def very_long_method_name_with_many_parameters(
  param1,
  param2,
  param3,
  param4,
  param5
)

# Bad: Missing frozen_string_literal
class MyClass

# Good: Add magic comment
# frozen_string_literal: true

class MyClass

# Bad: Using `and`/`or`
if condition and other_condition

# Good: Using `&&`/`||`
if condition && other_condition
```

## Common Brakeman Fixes

```ruby
# Bad: SQL injection
User.where("name = '#{params[:name]}'")

# Good: Parameterized query
User.where(name: params[:name])
User.where("name = ?", params[:name])

# Bad: Mass assignment
User.create(params[:user])

# Good: Strong parameters
User.create(user_params)

# Bad: Redirect to user input
redirect_to params[:url]

# Good: Validate redirect
redirect_to allowed_redirect_path
```

## PR Template

```markdown
## Summary

[Brief description of changes]

## Type of Change

- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing

- [ ] Added/updated unit tests
- [ ] Added/updated request specs
- [ ] Manually tested locally

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Tests pass locally
- [ ] Documentation updated (if needed)
- [ ] No security vulnerabilities introduced

## Screenshots (if UI changes)

[Add screenshots here]
```

## Commands to Run Before PR

```bash
# Full quality check script
#!/bin/bash
set -e

echo "Running Rubocop..."
bundle exec rubocop -A

echo "Running Brakeman..."
bundle exec brakeman --no-pager

echo "Running RSpec..."
bundle exec rspec

echo "All checks passed!"
```

## Checklist

Before approving code:

- [ ] All quality commands pass
- [ ] Pre-PR checklist completed
- [ ] No security vulnerabilities
- [ ] Code is readable and maintainable
