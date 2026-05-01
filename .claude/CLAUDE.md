# Rocketpass Starterpack Rails - Project Rules

## Overview

This is a Rails API starter pack for rapid product development targeting web (Hotwire/Turbo) and mobile (API-first) platforms.

## Code Structure

- Follow Rails conventions with service layer pattern
- Controllers delegate to services, never contain business logic
- Use Blueprinter for all API serialization
- snake_case for files, methods, variables
- Prefer composition over inheritance

## Multi-tenancy (ActsAsTenant)

- All tenant data MUST be scoped via `acts_as_tenant :account`
- `superadmin` bypasses tenant scope (global access)
- `admin` is tenant-bound (account-specific)
- Never create unscoped queries for tenant models
- Always test tenant isolation in specs

## API Standards

- Version all endpoints under `/api/v1/`
- Response format: `{ data: ..., meta: { ... } }`
- Error format: `{ error: "message", code: "error_code" }`
- Pagination via Pagy (`page`, `per_page` params)
- Authentication: Bearer token (JWT) or Doorkeeper OAuth
- Always update Swagger documentation when modifying endpoints

## Service Layer Pattern

```ruby
# Location: app/services/<domain>/<action>_service.rb
class Domain::ActionService < ApplicationService
  def initialize(params:, user:)
    @params = params
    @user = user
  end

  def call
    # Business logic here
    if success_condition
      success(result)
    else
      failure("Error message", code: :error_code)
    end
  end
end
```

## Testing (TDD Required)

- Write tests BEFORE implementation (Red → Green → Refactor)
- Request specs for all API endpoints (`spec/requests/`)
- Model specs for validations and scopes (`spec/models/`)
- Service specs for business logic (`spec/services/`)
- Use FactoryBot for test data
- Minimum 80% coverage target
- Always test tenant scoping

## Background Jobs

- Workers in `app/workers/`
- Use Sidekiq best practices:
  - Idempotent operations
  - Small serializable payloads
  - Configure retries appropriately
- Test workers with `Sidekiq::Testing.inline!`

## Hotwire/Turbo Frontend

- Use Turbo Frames for partial page updates
- Use Turbo Streams for real-time updates
- Stimulus controllers in `app/javascript/controllers/`
- Keep controllers small and focused

## Quality Gates (Must Pass Before PR)

```bash
bundle exec rubocop        # No offenses
bundle exec brakeman       # No warnings
bundle exec rspec          # All tests pass
```

## Development Workflow

1. **Plan** - Understand requirements, design solution
2. **TDD** - Write failing tests first
3. **Implement** - Write minimal code to pass tests
4. **Quality** - Run rubocop, brakeman, full test suite
5. **Review** - Self-review, verify tenant scoping
6. **PR** - Create PR, wait for CI, merge

## Agents

This project includes specialized Claude Code agents in `.claude/agents/`:

- `product-agent` - Orchestrator for feature requests
- `model-agent` - Database models and migrations
- `api-agent` - Controllers, services, serializers
- `ui-agent` - Hotwire views and Stimulus
- `test-agent` - RSpec test generation
- `job-agent` - Sidekiq workers
- `mobile-sdk-agent` - API docs and SDK generation
- `review-agent` - Code quality checks
- `deploy-agent` - Deployment operations

Use agents via: `@product-agent add user profile feature`
