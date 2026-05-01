# Claude Code Agents Design Specification

**Date:** 2026-05-01  
**Status:** Draft  
**Author:** Yunus Erdem Sıhhatlı  

## Overview

This specification defines a Claude Code agent system for the Rocketpass Starterpack Rails project. The goal is to accelerate product development for both web (Hotwire/Turbo) and mobile (API-first) platforms through specialized AI agents.

## Goals

1. Rapid feature development with TDD-first workflow
2. Consistent code quality across all layers
3. Mobile-ready API with auto-generated SDKs and documentation
4. Automated CI/CD with security checks
5. Single orchestrator entry point for feature requests

## Architecture

### Agent Hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRODUCT-AGENT (Orchestrator)               │
│              Receives feature requests, delegates work          │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  MODEL-AGENT  │    │   API-AGENT   │    │   UI-AGENT    │
│  Migrations   │    │  Controllers  │    │    Views      │
│  Models       │    │  Services     │    │   Stimulus    │
│  Validations  │    │  Serializers  │    │  Turbo Frames │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  TEST-AGENT   │    │   JOB-AGENT   │    │MOBILE-SDK-AGT │
│ Request specs │    │ Sidekiq       │    │ Postman       │
│ Model specs   │    │ workers       │    │ curl examples │
│ Service specs │    │ Scheduled     │    │ TypeScript SDK│
│ Factories     │    │ jobs          │    │ Swift SDK     │
└───────────────┘    └───────────────┘    └───────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐
│ REVIEW-AGENT  │    │ DEPLOY-AGENT  │
│ Rubocop       │    │ Kamal         │
│ Brakeman      │    │ Environment   │
│ Code quality  │    │ Rollback      │
│ PR checklist  │    │ Health checks │
└───────────────┘    └───────────────┘
```

### File Structure

```
.claude/
├── CLAUDE.md                      # Project rules and conventions
├── agents/
│   ├── product-agent.md           # Orchestrator - main entry point
│   ├── model-agent.md             # Database models, migrations
│   ├── api-agent.md               # Controllers, services, serializers
│   ├── ui-agent.md                # Hotwire, Stimulus, views
│   ├── test-agent.md              # RSpec test generation
│   ├── job-agent.md               # Sidekiq workers, scheduled jobs
│   ├── mobile-sdk-agent.md        # SDK generation, API docs
│   ├── review-agent.md            # Code quality, PR review
│   └── deploy-agent.md            # Deployment operations
└── workflows/
    └── development-workflow.md    # TDD-first development process
```

## Agent Specifications

### 1. Product Agent (Orchestrator)

**Purpose:** Single entry point for feature requests. Understands requirements, creates plans, and delegates to specialized agents.

**Responsibilities:**
- Parse high-level feature requests
- Create implementation plans
- Delegate to appropriate agents in correct order
- Ensure consistency across layers
- Follow development workflow

**Example Usage:**
```
User: "Add user profile feature with avatar upload"

Product Agent:
1. Creates plan (model, API, UI, tests)
2. Delegates to model-agent (Profile model, migration)
3. Delegates to api-agent (endpoints, service, serializer)
4. Delegates to ui-agent (Hotwire views, Stimulus)
5. Delegates to test-agent (specs for all layers)
6. Delegates to review-agent (quality check)
```

### 2. Model Agent

**Purpose:** Handle all database-related tasks.

**Responsibilities:**
- Generate migrations
- Create models with validations
- Define associations and scopes
- Add concerns when appropriate
- Ensure ActsAsTenant scoping

**Patterns:**
```ruby
# Always scope tenant models
class Feature < ApplicationRecord
  acts_as_tenant :account
  
  belongs_to :user
  
  validates :name, presence: true
  
  scope :active, -> { where(active: true) }
end
```

### 3. API Agent

**Purpose:** Build API layer following project conventions.

**Responsibilities:**
- Create controllers under `Api::V1::`
- Build services in `app/services/`
- Generate Blueprinter serializers
- Create Pundit policies
- Update Swagger documentation

**Patterns:**
```ruby
# Controller delegates to service
class Api::V1::FeaturesController < Api::V1::BaseController
  def create
    result = Features::CreateService.call(params: feature_params, user: current_user)
    
    if result.success?
      render json: FeatureBlueprint.render(result.value), status: :created
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end

# Service returns Result object
class Features::CreateService < ApplicationService
  def initialize(params:, user:)
    @params = params
    @user = user
  end

  def call
    feature = Feature.new(@params)
    feature.user = @user
    
    if feature.save
      success(feature)
    else
      failure(feature.errors.full_messages.join(", "))
    end
  end
end
```

### 4. UI Agent

**Purpose:** Build Hotwire/Turbo frontend components.

**Responsibilities:**
- Create views with Turbo Frames
- Generate Stimulus controllers
- Build Turbo Stream responses
- Create partials for reusability
- Follow Rails view conventions

**Patterns:**
```erb
<!-- Turbo Frame for inline editing -->
<%= turbo_frame_tag dom_id(feature) do %>
  <div data-controller="feature">
    <%= render "features/show", feature: feature %>
  </div>
<% end %>
```

```javascript
// Stimulus controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  
  connect() {
    // Initialize
  }
  
  submit() {
    // Handle form submission
  }
}
```

### 5. Test Agent

**Purpose:** Generate comprehensive RSpec tests following TDD.

**Responsibilities:**
- Write request specs for API endpoints
- Create model specs for validations
- Generate service specs for business logic
- Build factories for test data
- Ensure tenant scoping is tested

**Patterns:**
```ruby
# Request spec
RSpec.describe "Api::V1::Features", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  
  before { ActsAsTenant.current_tenant = account }
  
  describe "POST /api/v1/features" do
    context "with valid params" do
      it "creates a feature" do
        post api_v1_features_path, 
             params: { feature: { name: "Test" } },
             headers: auth_headers(user)
        
        expect(response).to have_http_status(:created)
        expect(json_response["data"]["name"]).to eq("Test")
      end
    end
  end
end
```

### 6. Job Agent

**Purpose:** Handle Sidekiq background job creation.

**Responsibilities:**
- Generate Sidekiq workers
- Configure queue priorities
- Set up scheduled jobs
- Implement retry logic
- Create worker specs

**Patterns:**
```ruby
# Idempotent worker
class FeatureProcessWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default, retry: 3
  
  def perform(feature_id)
    feature = Feature.find_by(id: feature_id)
    return unless feature # Idempotent - handle deleted records
    
    Features::ProcessService.call(feature: feature)
  end
end
```

### 7. Mobile SDK Agent

**Purpose:** Generate mobile-friendly API documentation and SDKs.

**Responsibilities:**
- Generate Postman collections from OpenAPI spec
- Create curl examples for each endpoint
- Generate TypeScript SDK (React Native)
- Generate Swift SDK (iOS)
- Generate Kotlin SDK (Android)

**Outputs:**
```
docs/
├── api/
│   ├── postman_collection.json
│   ├── curl_examples.md
│   └── sdk/
│       ├── typescript/
│       ├── swift/
│       └── kotlin/
```

### 8. Review Agent

**Purpose:** Ensure code quality before PR.

**Responsibilities:**
- Run Rubocop and fix issues
- Run Brakeman security scan
- Check test coverage
- Verify API documentation updated
- Ensure tenant scoping correct
- Generate PR checklist

**Quality Gates:**
```bash
bundle exec rubocop -A          # Auto-fix style issues
bundle exec brakeman --no-pager # Security scan
bundle exec rspec               # All tests pass
```

### 9. Deploy Agent

**Purpose:** Handle deployment operations.

**Responsibilities:**
- Execute Kamal deployment commands
- Manage environment variables
- Perform health checks
- Handle rollback procedures
- Monitor deployment status

**Commands:**
```bash
bin/kamal deploy              # Deploy to production
bin/kamal rollback            # Rollback to previous version
bin/kamal app logs            # Check application logs
bin/kamal audit               # Verify configuration
```

## Development Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT WORKFLOW                         │
└─────────────────────────────────────────────────────────────────┘

1. PLAN
   ├── Understand requirements
   ├── Design data models
   ├── Define API endpoints
   └── Create implementation plan

2. TDD (Test First)
   ├── Write failing request specs
   ├── Write failing model specs
   ├── Write failing service specs
   └── Red → Green → Refactor

3. IMPLEMENT
   ├── Model + migrations
   ├── Service layer
   ├── Controller + serializer
   ├── Hotwire views (if needed)
   └── API documentation

4. QUALITY
   ├── bundle exec rubocop -A
   ├── bundle exec brakeman
   ├── bundle exec rspec
   └── Code cleanup & refactor

5. REVIEW
   ├── Self code review
   ├── Check test coverage
   ├── Verify API docs updated
   └── Ensure tenant-scoping correct

6. PR & MERGE
   ├── Create PR with description
   ├── CI passes (tests, lint, security)
   ├── Merge to main
   └── Auto-deploy triggers
```

## CI/CD Pipeline

### ci.yml (On push, pull_request)

```yaml
jobs:
  lint:
    - bundle exec rubocop
    
  security:
    - bundle exec brakeman --no-pager
    - bundle audit check
    
  test:
    - bundle exec rspec
    - Upload coverage report
    
  build:
    - Docker image build test (optional)
```

### deploy.yml (On push to main)

```yaml
jobs:
  deploy:
    needs: [ci passes]
    steps:
      - bin/kamal deploy
      - Health check
      - Notify (Slack/Discord - optional)
```

## CLAUDE.md Rules

```markdown
# Project Rules

## Code Structure
- Follow Rails conventions with service layer pattern
- Controllers delegate to services, never contain business logic
- Use Blueprinter for all API serialization
- snake_case for files, methods, variables

## Multi-tenancy
- All tenant data MUST be scoped via ActsAsTenant
- superadmin bypasses tenant scope (global access)
- admin is tenant-bound (account-specific)
- Never create unscoped queries for tenant models

## API Standards
- Version all endpoints under /api/v1/
- Use consistent response format: { data: ..., meta: ... }
- Pagination via Pagy (page, per_page params)
- Authentication: Bearer token (JWT) or Doorkeeper OAuth

## Service Layer
- Inherit from ApplicationService
- Use .call class method
- Return Service::Result (success/failure)
- Keep services single-purpose

## Testing (TDD Required)
- Write tests BEFORE implementation
- Request specs for all endpoints
- Model specs for validations/scopes
- Service specs for business logic
- Minimum 80% coverage target

## Background Jobs
- Workers in app/workers/
- Use Sidekiq best practices (idempotent, small payloads)
- Configure retries and dead letter queues

## Quality Gates
- rubocop must pass (no offenses)
- brakeman must pass (no warnings)
- All specs green before PR

## Development Workflow
1. Plan → 2. TDD → 3. Implement → 4. Quality → 5. Review → 6. PR
```

## Implementation Plan

### Phase 1: Foundation
1. Create `.claude/` directory structure
2. Write `CLAUDE.md` with project rules
3. Create `development-workflow.md`

### Phase 2: Core Agents
4. Implement `product-agent.md` (orchestrator)
5. Implement `model-agent.md`
6. Implement `api-agent.md`
7. Implement `test-agent.md`

### Phase 3: UI & Jobs
8. Implement `ui-agent.md`
9. Implement `job-agent.md`

### Phase 4: Quality & Deployment
10. Implement `review-agent.md`
11. Implement `deploy-agent.md`
12. Implement `mobile-sdk-agent.md`

### Phase 5: CI/CD & Documentation
13. Update `.github/workflows/ci.yml`
14. Update `.github/workflows/deploy.yml`
15. Update `README.md` with agent guide

## Success Criteria

1. All 9 agents created and functional
2. Development workflow documented
3. CI/CD pipeline enhanced
4. README updated with usage guide
5. Existing tests continue to pass
6. Rubocop and Brakeman checks pass

## Dependencies

- Existing Rails application structure
- Sidekiq + Redis for background jobs
- RSwag for OpenAPI spec generation
- Kamal for deployment
- GitHub Actions for CI/CD

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Agent complexity | Start with core agents, iterate |
| Inconsistent outputs | Strong CLAUDE.md rules |
| SDK generation errors | Use OpenAPI spec as source of truth |
| Breaking existing code | TDD ensures no regressions |
