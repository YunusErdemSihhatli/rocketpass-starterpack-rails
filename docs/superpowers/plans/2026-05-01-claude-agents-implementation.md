# Claude Code Agents Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a Claude Code agent system with 9 specialized agents and TDD-first development workflow for rapid product development.

**Architecture:** Orchestrator pattern with product-agent as entry point, delegating to specialized agents (model, api, ui, test, job, mobile-sdk, review, deploy). All agents follow CLAUDE.md rules and development-workflow.md process.

**Tech Stack:** Claude Code agents (.md files), GitHub Actions (CI/CD), Kamal (deployment), Rails 7+ with Hotwire/Turbo

---

## File Structure

```
.claude/
├── CLAUDE.md                           # Project rules (create)
├── agents/
│   ├── product-agent.md                # Orchestrator (create)
│   ├── model-agent.md                  # Database layer (create)
│   ├── api-agent.md                    # API layer (create)
│   ├── ui-agent.md                     # Frontend layer (create)
│   ├── test-agent.md                   # Testing (create)
│   ├── job-agent.md                    # Background jobs (create)
│   ├── mobile-sdk-agent.md             # Mobile SDK generation (create)
│   ├── review-agent.md                 # Code quality (create)
│   └── deploy-agent.md                 # Deployment (create)
└── workflows/
    └── development-workflow.md         # TDD process (create)

.github/workflows/
├── ci.yml                              # Existing, will enhance
└── deploy.yml                          # Create for auto-deploy

README.md                               # Update with agent guide
```

---

## Phase 1: Foundation

### Task 1: Create Directory Structure

**Files:**
- Create: `.claude/agents/` (directory)
- Create: `.claude/workflows/` (directory)

- [ ] **Step 1: Create .claude directory structure**

```bash
mkdir -p .claude/agents .claude/workflows
```

- [ ] **Step 2: Verify structure exists**

```bash
ls -la .claude/
```

Expected output:
```
drwxr-xr-x  agents
drwxr-xr-x  workflows
```

- [ ] **Step 3: Commit**

```bash
git add .claude/
git commit -m "chore: create .claude directory structure for agents"
```

---

### Task 2: Create CLAUDE.md Project Rules

**Files:**
- Create: `.claude/CLAUDE.md`

- [ ] **Step 1: Write CLAUDE.md with project rules**

```markdown
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
```

- [ ] **Step 2: Verify file content**

```bash
head -20 .claude/CLAUDE.md
```

- [ ] **Step 3: Commit**

```bash
git add .claude/CLAUDE.md
git commit -m "docs: add CLAUDE.md with project rules and conventions"
```

---

### Task 3: Create Development Workflow

**Files:**
- Create: `.claude/workflows/development-workflow.md`

- [ ] **Step 1: Write development-workflow.md**

```markdown
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
```

- [ ] **Step 2: Verify file exists**

```bash
wc -l .claude/workflows/development-workflow.md
```

Expected: ~150 lines

- [ ] **Step 3: Commit**

```bash
git add .claude/workflows/development-workflow.md
git commit -m "docs: add TDD-first development workflow"
```

---

## Phase 2: Core Agents

### Task 4: Create Product Agent (Orchestrator)

**Files:**
- Create: `.claude/agents/product-agent.md`

- [ ] **Step 1: Write product-agent.md**

```markdown
---
name: product-agent
description: Orchestrator agent for feature requests. Delegates to specialized agents.
---

# Product Agent

You are the orchestrator agent for Rocketpass Starterpack Rails. You receive high-level feature requests and coordinate specialized agents to implement them.

## Your Role

1. **Understand** the feature request
2. **Plan** the implementation approach
3. **Delegate** to specialized agents in the correct order
4. **Verify** consistency across all layers
5. **Ensure** the development workflow is followed

## Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `model-agent` | Database models, migrations | Need new tables or model changes |
| `api-agent` | Controllers, services, serializers | Need API endpoints |
| `ui-agent` | Hotwire views, Stimulus | Need web UI |
| `test-agent` | RSpec tests | Need test coverage |
| `job-agent` | Sidekiq workers | Need background processing |
| `mobile-sdk-agent` | API docs, SDKs | Need mobile documentation |
| `review-agent` | Code quality | Before PR |
| `deploy-agent` | Deployment | Deploy to production |

## Delegation Order

For a typical feature, delegate in this order:

1. **test-agent** - Write failing tests first (TDD)
2. **model-agent** - Create models and migrations
3. **api-agent** - Create API layer
4. **ui-agent** - Create web UI (if needed)
5. **job-agent** - Create background jobs (if needed)
6. **mobile-sdk-agent** - Update API docs
7. **review-agent** - Quality checks

## Example Interaction

**User:** "Add user profile feature with avatar upload"

**Your Response:**

I'll coordinate the implementation of the user profile feature with avatar upload.

**Plan:**
1. Profile model with avatar attachment (Active Storage)
2. API endpoints: GET/PATCH /api/v1/profile
3. Service for avatar processing
4. Hotwire views for web UI
5. Request and model specs

**Delegating to agents:**

1. @test-agent: Write specs for Profile model and API endpoints
2. @model-agent: Create Profile model with avatar attachment
3. @api-agent: Create ProfilesController and ProfileBlueprint
4. @ui-agent: Create profile edit view with Turbo Frame
5. @review-agent: Run quality checks

## Rules

1. **Always follow TDD** - Tests come before implementation
2. **Follow CLAUDE.md** - Respect all project conventions
3. **Check tenant scoping** - Ensure multi-tenancy is correct
4. **Update documentation** - API docs must stay current
5. **Run quality gates** - Never skip rubocop/brakeman/rspec

## Response Format

When receiving a feature request:

```
## Understanding

[Restate the feature in your own words]

## Plan

1. [Component 1]
2. [Component 2]
...

## Delegation

1. @agent-name: [specific task]
2. @agent-name: [specific task]
...

## Questions (if any)

- [Clarifying question]
```
```

- [ ] **Step 2: Verify file exists**

```bash
head -30 .claude/agents/product-agent.md
```

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/product-agent.md
git commit -m "feat: add product-agent orchestrator"
```

---

### Task 5: Create Model Agent

**Files:**
- Create: `.claude/agents/model-agent.md`

- [ ] **Step 1: Write model-agent.md**

```markdown
---
name: model-agent
description: Handles database models, migrations, validations, and associations
---

# Model Agent

You create and modify database models following Rails and project conventions.

## Responsibilities

- Generate migrations
- Create models with validations
- Define associations (belongs_to, has_many, etc.)
- Add scopes and class methods
- Ensure ActsAsTenant scoping for tenant models

## Conventions

### File Locations

- Models: `app/models/`
- Migrations: `db/migrate/`
- Concerns: `app/models/concerns/`

### Multi-tenancy

All tenant-scoped models MUST include:

```ruby
class Feature < ApplicationRecord
  acts_as_tenant :account
  
  # ... rest of model
end
```

### Standard Model Structure

```ruby
class Feature < ApplicationRecord
  # 1. Tenant scoping (if applicable)
  acts_as_tenant :account
  
  # 2. Associations
  belongs_to :user
  has_many :items, dependent: :destroy
  
  # 3. Validations
  validates :name, presence: true
  validates :status, inclusion: { in: %w[draft active archived] }
  
  # 4. Scopes
  scope :active, -> { where(status: 'active') }
  scope :recent, -> { order(created_at: :desc) }
  
  # 5. Callbacks (use sparingly)
  before_validation :set_defaults, on: :create
  
  # 6. Class methods
  def self.search(query)
    where('name ILIKE ?', "%#{query}%")
  end
  
  # 7. Instance methods
  def active?
    status == 'active'
  end
  
  private
  
  def set_defaults
    self.status ||= 'draft'
  end
end
```

### Migration Conventions

```ruby
class CreateFeatures < ActiveRecord::Migration[7.1]
  def change
    create_table :features do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :status, default: 'draft'
      t.text :description
      
      t.timestamps
    end
    
    add_index :features, [:account_id, :name], unique: true
  end
end
```

## Commands

```bash
# Generate migration
bin/rails generate migration CreateFeatures name:string status:string

# Run migration
bin/rails db:migrate

# Rollback
bin/rails db:rollback

# Check migration status
bin/rails db:migrate:status
```

## Checklist

Before completing:

- [ ] Migration creates correct columns and indexes
- [ ] Model has all necessary validations
- [ ] Associations are correctly defined
- [ ] Tenant scoping added (if tenant model)
- [ ] Scopes are tested
- [ ] No N+1 queries introduced
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/model-agent.md
git commit -m "feat: add model-agent for database operations"
```

---

### Task 6: Create API Agent

**Files:**
- Create: `.claude/agents/api-agent.md`

- [ ] **Step 1: Write api-agent.md**

```markdown
---
name: api-agent
description: Creates API controllers, services, serializers, and policies
---

# API Agent

You build the API layer following Rails and project conventions.

## Responsibilities

- Create controllers under `Api::V1::`
- Build services in `app/services/`
- Generate Blueprinter serializers
- Create Pundit policies
- Update Swagger documentation

## File Locations

- Controllers: `app/controllers/api/v1/`
- Services: `app/services/<domain>/`
- Serializers: `app/blueprints/`
- Policies: `app/policies/`

## Controller Pattern

```ruby
# app/controllers/api/v1/features_controller.rb
module Api
  module V1
    class FeaturesController < BaseController
      before_action :set_feature, only: [:show, :update, :destroy]
      
      # GET /api/v1/features
      def index
        @features = policy_scope(Feature)
        @pagy, @features = pagy(@features)
        
        render json: FeatureBlueprint.render(@features, root: :data, meta: pagy_metadata(@pagy))
      end
      
      # GET /api/v1/features/:id
      def show
        authorize @feature
        render json: FeatureBlueprint.render(@feature, root: :data)
      end
      
      # POST /api/v1/features
      def create
        authorize Feature
        result = Features::CreateService.call(params: feature_params, user: current_user)
        
        if result.success?
          render json: FeatureBlueprint.render(result.value, root: :data), status: :created
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      # PATCH /api/v1/features/:id
      def update
        authorize @feature
        result = Features::UpdateService.call(feature: @feature, params: feature_params)
        
        if result.success?
          render json: FeatureBlueprint.render(result.value, root: :data)
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/features/:id
      def destroy
        authorize @feature
        result = Features::DestroyService.call(feature: @feature)
        
        if result.success?
          head :no_content
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_feature
        @feature = Feature.find(params[:id])
      end
      
      def feature_params
        params.require(:feature).permit(:name, :description, :status)
      end
    end
  end
end
```

## Service Pattern

```ruby
# app/services/features/create_service.rb
module Features
  class CreateService < ApplicationService
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
        failure(feature.errors.full_messages.join(", "), code: :validation_error)
      end
    end
  end
end
```

## Serializer Pattern

```ruby
# app/blueprints/feature_blueprint.rb
class FeatureBlueprint < Blueprinter::Base
  identifier :id
  
  fields :name, :status, :description, :created_at, :updated_at
  
  association :user, blueprint: UserBlueprint
  
  view :minimal do
    fields :name, :status
  end
  
  view :detailed do
    include_view :default
    association :items, blueprint: ItemBlueprint
  end
end
```

## Policy Pattern

```ruby
# app/policies/feature_policy.rb
class FeaturePolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    owner_or_admin?
  end
  
  def create?
    true
  end
  
  def update?
    owner_or_admin?
  end
  
  def destroy?
    owner_or_admin?
  end
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  private
  
  def owner_or_admin?
    record.user == user || user.has_role?(:admin)
  end
end
```

## Routes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :features, only: [:index, :show, :create, :update, :destroy]
  end
end
```

## Checklist

Before completing:

- [ ] Controller follows RESTful conventions
- [ ] Services handle business logic
- [ ] Serializer exposes only needed fields
- [ ] Policy restricts access appropriately
- [ ] Routes are added
- [ ] Swagger documentation updated
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/api-agent.md
git commit -m "feat: add api-agent for API layer development"
```

---

### Task 7: Create Test Agent

**Files:**
- Create: `.claude/agents/test-agent.md`

- [ ] **Step 1: Write test-agent.md**

```markdown
---
name: test-agent
description: Generates RSpec tests following TDD principles
---

# Test Agent

You write comprehensive RSpec tests following TDD principles.

## Responsibilities

- Write request specs for API endpoints
- Create model specs for validations and scopes
- Generate service specs for business logic
- Build factories for test data
- Ensure tenant scoping is tested

## File Locations

- Request specs: `spec/requests/api/v1/`
- Model specs: `spec/models/`
- Service specs: `spec/services/`
- Factories: `spec/factories/`
- Support files: `spec/support/`

## TDD Process

1. **Write failing test** - Define expected behavior
2. **Run test** - Confirm it fails for the right reason
3. **Write minimal code** - Just enough to pass
4. **Run test** - Confirm it passes
5. **Refactor** - Clean up while keeping tests green

## Request Spec Pattern

```ruby
# spec/requests/api/v1/features_spec.rb
require 'rails_helper'

RSpec.describe "Api::V1::Features", type: :request do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:headers) { auth_headers(user) }
  
  before { ActsAsTenant.current_tenant = account }
  
  describe "GET /api/v1/features" do
    let!(:features) { create_list(:feature, 3, user: user) }
    
    it "returns paginated features" do
      get api_v1_features_path, headers: headers
      
      expect(response).to have_http_status(:ok)
      expect(json_response["data"].size).to eq(3)
      expect(json_response["meta"]).to include("page", "items")
    end
    
    it "requires authentication" do
      get api_v1_features_path
      
      expect(response).to have_http_status(:unauthorized)
    end
  end
  
  describe "POST /api/v1/features" do
    let(:valid_params) { { feature: { name: "Test Feature", description: "Description" } } }
    let(:invalid_params) { { feature: { name: "" } } }
    
    context "with valid params" do
      it "creates a feature" do
        expect {
          post api_v1_features_path, params: valid_params, headers: headers
        }.to change(Feature, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response["data"]["name"]).to eq("Test Feature")
      end
    end
    
    context "with invalid params" do
      it "returns validation errors" do
        post api_v1_features_path, params: invalid_params, headers: headers
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response["error"]).to be_present
      end
    end
  end
  
  describe "tenant isolation" do
    let(:other_account) { create(:account) }
    let(:other_feature) { create(:feature, user: create(:user, account: other_account)) }
    
    before { ActsAsTenant.current_tenant = other_account; other_feature; ActsAsTenant.current_tenant = account }
    
    it "does not return features from other tenants" do
      get api_v1_features_path, headers: headers
      
      expect(json_response["data"]).to be_empty
    end
  end
end
```

## Model Spec Pattern

```ruby
# spec/models/feature_spec.rb
require 'rails_helper'

RSpec.describe Feature, type: :model do
  let(:account) { create(:account) }
  
  before { ActsAsTenant.current_tenant = account }
  
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:items).dependent(:destroy) }
  end
  
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft active archived]) }
  end
  
  describe "scopes" do
    let!(:active_feature) { create(:feature, status: 'active') }
    let!(:draft_feature) { create(:feature, status: 'draft') }
    
    describe ".active" do
      it "returns only active features" do
        expect(Feature.active).to contain_exactly(active_feature)
      end
    end
  end
  
  describe "#active?" do
    it "returns true when status is active" do
      feature = build(:feature, status: 'active')
      expect(feature.active?).to be true
    end
    
    it "returns false when status is not active" do
      feature = build(:feature, status: 'draft')
      expect(feature.active?).to be false
    end
  end
end
```

## Service Spec Pattern

```ruby
# spec/services/features/create_service_spec.rb
require 'rails_helper'

RSpec.describe Features::CreateService do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  
  before { ActsAsTenant.current_tenant = account }
  
  describe ".call" do
    context "with valid params" do
      let(:params) { { name: "Test", description: "Description" } }
      
      it "creates a feature" do
        result = described_class.call(params: params, user: user)
        
        expect(result).to be_success
        expect(result.value).to be_a(Feature)
        expect(result.value.name).to eq("Test")
      end
    end
    
    context "with invalid params" do
      let(:params) { { name: "" } }
      
      it "returns failure" do
        result = described_class.call(params: params, user: user)
        
        expect(result).to be_failure
        expect(result.error).to include("Name")
      end
    end
  end
end
```

## Factory Pattern

```ruby
# spec/factories/features.rb
FactoryBot.define do
  factory :feature do
    association :user
    account { user.account }
    name { Faker::Lorem.word }
    status { 'draft' }
    description { Faker::Lorem.paragraph }
    
    trait :active do
      status { 'active' }
    end
    
    trait :archived do
      status { 'archived' }
    end
  end
end
```

## Commands

```bash
# Run specific spec
bundle exec rspec spec/requests/api/v1/features_spec.rb

# Run with verbose output
bundle exec rspec spec/requests/api/v1/features_spec.rb -fd

# Run single example
bundle exec rspec spec/requests/api/v1/features_spec.rb:25

# Run all specs
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec
```

## Checklist

Before completing:

- [ ] Request specs cover all endpoints
- [ ] Model specs test validations and scopes
- [ ] Service specs test success and failure cases
- [ ] Factories are complete and valid
- [ ] Tenant isolation is tested
- [ ] Edge cases are covered
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/test-agent.md
git commit -m "feat: add test-agent for TDD test generation"
```

---

## Phase 3: UI & Jobs Agents

### Task 8: Create UI Agent

**Files:**
- Create: `.claude/agents/ui-agent.md`

- [ ] **Step 1: Write ui-agent.md**

```markdown
---
name: ui-agent
description: Creates Hotwire/Turbo views and Stimulus controllers
---

# UI Agent

You build Hotwire/Turbo frontend components following Rails conventions.

## Responsibilities

- Create views with Turbo Frames
- Generate Stimulus controllers
- Build Turbo Stream responses
- Create partials for reusability
- Follow Rails view conventions

## File Locations

- Views: `app/views/`
- Stimulus controllers: `app/javascript/controllers/`
- Layouts: `app/views/layouts/`
- Partials: `app/views/shared/` or within resource folder

## Turbo Frame Pattern

```erb
<%# app/views/features/index.html.erb %>
<div class="features">
  <h1>Features</h1>
  
  <%= turbo_frame_tag "features" do %>
    <% @features.each do |feature| %>
      <%= render "feature", feature: feature %>
    <% end %>
  <% end %>
  
  <%= link_to "New Feature", new_feature_path, data: { turbo_frame: "modal" } %>
</div>

<%# app/views/features/_feature.html.erb %>
<%= turbo_frame_tag dom_id(feature) do %>
  <div class="feature" data-controller="feature">
    <h3><%= feature.name %></h3>
    <p><%= feature.description %></p>
    <span class="status <%= feature.status %>"><%= feature.status %></span>
    
    <div class="actions">
      <%= link_to "Edit", edit_feature_path(feature) %>
      <%= button_to "Delete", feature_path(feature), method: :delete, 
            data: { turbo_confirm: "Are you sure?" } %>
    </div>
  </div>
<% end %>
```

## Turbo Stream Pattern

```erb
<%# app/views/features/create.turbo_stream.erb %>
<%= turbo_stream.prepend "features" do %>
  <%= render "feature", feature: @feature %>
<% end %>

<%= turbo_stream.update "flash" do %>
  <%= render "shared/flash", message: "Feature created successfully" %>
<% end %>

<%# app/views/features/update.turbo_stream.erb %>
<%= turbo_stream.replace dom_id(@feature) do %>
  <%= render "feature", feature: @feature %>
<% end %>

<%# app/views/features/destroy.turbo_stream.erb %>
<%= turbo_stream.remove dom_id(@feature) %>
```

## Stimulus Controller Pattern

```javascript
// app/javascript/controllers/feature_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "status", "output"]
  static values = { 
    id: Number,
    url: String 
  }
  
  connect() {
    console.log("Feature controller connected", this.idValue)
  }
  
  toggle(event) {
    event.preventDefault()
    this.statusTarget.classList.toggle("active")
  }
  
  async submit(event) {
    event.preventDefault()
    
    const formData = new FormData(this.formTarget)
    
    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        body: formData,
        headers: {
          "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
        }
      })
      
      if (response.ok) {
        this.outputTarget.textContent = "Saved!"
      }
    } catch (error) {
      console.error("Error:", error)
    }
  }
  
  disconnect() {
    // Cleanup
  }
}
```

## Form Pattern

```erb
<%# app/views/features/_form.html.erb %>
<%= form_with model: feature, data: { controller: "form", action: "submit->form#validate" } do |f| %>
  <% if feature.errors.any? %>
    <div class="errors">
      <% feature.errors.full_messages.each do |message| %>
        <p><%= message %></p>
      <% end %>
    </div>
  <% end %>
  
  <div class="field">
    <%= f.label :name %>
    <%= f.text_field :name, data: { form_target: "input" } %>
  </div>
  
  <div class="field">
    <%= f.label :description %>
    <%= f.text_area :description, rows: 4 %>
  </div>
  
  <div class="field">
    <%= f.label :status %>
    <%= f.select :status, Feature::STATUSES, {}, data: { action: "change->form#statusChanged" } %>
  </div>
  
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>
```

## Modal Pattern

```erb
<%# app/views/layouts/_modal.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal" data-controller="modal" data-action="keydown.esc->modal#close">
    <div class="modal-backdrop" data-action="click->modal#close"></div>
    <div class="modal-content">
      <%= yield %>
      <button data-action="click->modal#close">Close</button>
    </div>
  </div>
<% end %>
```

```javascript
// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.body.classList.add("modal-open")
  }
  
  close() {
    this.element.remove()
    document.body.classList.remove("modal-open")
  }
  
  disconnect() {
    document.body.classList.remove("modal-open")
  }
}
```

## Checklist

Before completing:

- [ ] Views use Turbo Frames appropriately
- [ ] Stimulus controllers are focused and small
- [ ] Forms use form_with (not form_for)
- [ ] Partials are reusable
- [ ] Turbo Streams handle create/update/delete
- [ ] Accessibility considered (aria labels, etc.)
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/ui-agent.md
git commit -m "feat: add ui-agent for Hotwire/Turbo development"
```

---

### Task 9: Create Job Agent

**Files:**
- Create: `.claude/agents/job-agent.md`

- [ ] **Step 1: Write job-agent.md**

```markdown
---
name: job-agent
description: Creates Sidekiq workers and scheduled jobs
---

# Job Agent

You create Sidekiq background jobs following best practices.

## Responsibilities

- Generate Sidekiq workers
- Configure queue priorities
- Set up scheduled jobs
- Implement retry logic
- Create worker specs

## File Locations

- Workers: `app/workers/`
- Scheduler config: `config/sidekiq.yml`
- Worker specs: `spec/workers/`

## Worker Pattern

```ruby
# app/workers/feature_process_worker.rb
class FeatureProcessWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :default, retry: 3, dead: true
  
  sidekiq_retry_in do |count, exception|
    case exception
    when NetworkError
      (count + 1) * 60 # Linear backoff for network issues
    else
      :kill # Don't retry other errors
    end
  end
  
  def perform(feature_id, options = {})
    # Idempotent: handle deleted records gracefully
    feature = Feature.find_by(id: feature_id)
    return unless feature
    
    # Set tenant context for multi-tenant operations
    ActsAsTenant.with_tenant(feature.account) do
      Features::ProcessService.call(feature: feature, **options.symbolize_keys)
    end
  end
end
```

## Queue Configuration

```yaml
# config/sidekiq.yml
:concurrency: 5
:timeout: 25

:queues:
  - [critical, 3]
  - [default, 2]
  - [low, 1]

# Scheduled jobs
:schedule:
  cleanup_failed_tasks:
    cron: '0 2 * * *'  # Daily at 2 AM
    class: CleanupFailedTasksWorker
    queue: low
    
  send_daily_digest:
    cron: '0 8 * * *'  # Daily at 8 AM
    class: SendDailyDigestWorker
    queue: default
```

## Batch Processing Pattern

```ruby
# app/workers/batch_feature_worker.rb
class BatchFeatureWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :low, retry: 1
  
  BATCH_SIZE = 100
  
  def perform(account_id)
    account = Account.find_by(id: account_id)
    return unless account
    
    ActsAsTenant.with_tenant(account) do
      Feature.find_in_batches(batch_size: BATCH_SIZE) do |batch|
        batch.each do |feature|
          FeatureProcessWorker.perform_async(feature.id)
        end
      end
    end
  end
end
```

## Worker with Logging

```ruby
# app/workers/important_worker.rb
class ImportantWorker
  include Sidekiq::Worker
  
  sidekiq_options queue: :critical, retry: 5
  
  def perform(record_id)
    logger.info "[ImportantWorker] Starting job for record #{record_id}"
    
    record = Record.find_by(id: record_id)
    unless record
      logger.warn "[ImportantWorker] Record #{record_id} not found, skipping"
      return
    end
    
    result = ProcessService.call(record: record)
    
    if result.success?
      logger.info "[ImportantWorker] Successfully processed record #{record_id}"
    else
      logger.error "[ImportantWorker] Failed to process record #{record_id}: #{result.error}"
      raise StandardError, result.error # Will trigger retry
    end
  end
end
```

## Worker Spec Pattern

```ruby
# spec/workers/feature_process_worker_spec.rb
require 'rails_helper'

RSpec.describe FeatureProcessWorker, type: :worker do
  let(:account) { create(:account) }
  let(:feature) { create(:feature, account: account) }
  
  describe "#perform" do
    it "processes the feature" do
      expect(Features::ProcessService).to receive(:call).with(feature: feature)
      
      described_class.new.perform(feature.id)
    end
    
    it "handles missing features gracefully" do
      expect {
        described_class.new.perform(0)
      }.not_to raise_error
    end
    
    it "sets tenant context" do
      described_class.new.perform(feature.id)
      
      # Verify tenant was set correctly during execution
    end
  end
  
  describe "queue configuration" do
    it "uses the default queue" do
      expect(described_class.sidekiq_options["queue"]).to eq("default")
    end
    
    it "retries 3 times" do
      expect(described_class.sidekiq_options["retry"]).to eq(3)
    end
  end
end
```

## Inline Testing

```ruby
# spec/rails_helper.rb
RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Testing.fake!
  end
  
  config.before(:each, :inline_jobs) do
    Sidekiq::Testing.inline!
  end
end

# Usage in spec
RSpec.describe "Feature creation", :inline_jobs do
  it "processes feature in background" do
    # Jobs will execute immediately
  end
end
```

## Commands

```bash
# Start Sidekiq
bundle exec sidekiq

# Start with specific config
bundle exec sidekiq -C config/sidekiq.yml

# Clear all queues (dev only)
Sidekiq::Queue.all.each(&:clear)

# Check queue sizes
Sidekiq::Queue.all.map { |q| [q.name, q.size] }
```

## Best Practices

1. **Idempotent** - Jobs should be safe to run multiple times
2. **Small payloads** - Pass IDs, not full objects
3. **Handle failures** - Use proper retry configuration
4. **Set tenant context** - Always wrap in ActsAsTenant.with_tenant
5. **Log appropriately** - Use structured logging
6. **Test thoroughly** - Unit test all worker logic

## Checklist

Before completing:

- [ ] Worker is idempotent
- [ ] Handles missing records gracefully
- [ ] Uses appropriate queue
- [ ] Retry configuration is sensible
- [ ] Tenant context is set
- [ ] Worker spec exists
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/job-agent.md
git commit -m "feat: add job-agent for Sidekiq worker development"
```

---

## Phase 4: Quality & Deployment Agents

### Task 10: Create Review Agent

**Files:**
- Create: `.claude/agents/review-agent.md`

- [ ] **Step 1: Write review-agent.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/review-agent.md
git commit -m "feat: add review-agent for code quality checks"
```

---

### Task 11: Create Deploy Agent

**Files:**
- Create: `.claude/agents/deploy-agent.md`

- [ ] **Step 1: Write deploy-agent.md**

```markdown
---
name: deploy-agent
description: Handles Kamal deployment operations
---

# Deploy Agent

You manage deployments using Kamal.

## Responsibilities

- Execute Kamal deployment commands
- Manage environment variables
- Perform health checks
- Handle rollback procedures
- Monitor deployment status

## Kamal Commands

```bash
# Initial setup (first deploy)
bin/kamal setup

# Deploy latest changes
bin/kamal deploy

# Deploy specific version
bin/kamal deploy --version=abc123

# Rollback to previous version
bin/kamal rollback

# Check deployment status
bin/kamal details

# View application logs
bin/kamal app logs

# Execute console on server
bin/kamal app exec -i 'bin/rails console'

# Run migrations
bin/kamal app exec 'bin/rails db:migrate'

# Verify configuration
bin/kamal audit

# Restart application
bin/kamal app boot

# Stop application
bin/kamal app stop
```

## Pre-Deploy Checklist

- [ ] All tests pass locally
- [ ] Rubocop and Brakeman pass
- [ ] Changes merged to main branch
- [ ] CI pipeline passes
- [ ] Database migrations reviewed (if any)
- [ ] Environment variables set (if new ones needed)

## Deploy Configuration

```yaml
# config/deploy.yml
service: rocketpass
image: your-registry/rocketpass

servers:
  web:
    hosts:
      - your-server-ip
    options:
      memory: 512m
  worker:
    hosts:
      - your-server-ip
    cmd: bundle exec sidekiq
    options:
      memory: 256m

registry:
  server: ghcr.io
  username: your-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  clear:
    RAILS_ENV: production
    RAILS_LOG_TO_STDOUT: true
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
    - REDIS_URL
    - SENTRY_DSN

traefik:
  options:
    publish:
      - "443:443"
    volume:
      - "/letsencrypt:/letsencrypt"
  args:
    entryPoints.websecure.address: ":443"
    certificatesResolvers.letsencrypt.acme.email: "your@email.com"
    certificatesResolvers.letsencrypt.acme.storage: "/letsencrypt/acme.json"
    certificatesResolvers.letsencrypt.acme.httpChallenge.entryPoint: "web"

healthcheck:
  path: /up
  port: 3000
  interval: 10s
```

## Environment Variables

Required secrets for deployment:

| Variable | Description |
|----------|-------------|
| `KAMAL_REGISTRY_PASSWORD` | Container registry password |
| `RAILS_MASTER_KEY` | Rails credentials key |
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `SENTRY_DSN` | Sentry error tracking |

## Rollback Procedure

If deployment fails or causes issues:

```bash
# 1. Check current status
bin/kamal details

# 2. View recent logs for errors
bin/kamal app logs --since 5m

# 3. Rollback to previous version
bin/kamal rollback

# 4. Verify rollback successful
bin/kamal details
curl -I https://your-domain.com/up
```

## Database Migrations

For migrations with potential downtime:

```bash
# 1. Put app in maintenance mode (optional)
bin/kamal app exec 'bin/rails maintenance:start'

# 2. Run migrations
bin/kamal app exec 'bin/rails db:migrate'

# 3. Verify migration success
bin/kamal app exec 'bin/rails db:migrate:status'

# 4. Remove maintenance mode
bin/kamal app exec 'bin/rails maintenance:end'
```

## Monitoring

```bash
# Check health endpoint
curl https://your-domain.com/up

# View application logs
bin/kamal app logs -f

# View Sidekiq logs
bin/kamal app logs -r worker -f

# Check container resources
bin/kamal app exec 'ps aux'
```

## Troubleshooting

### Deploy fails at boot
```bash
# Check logs for errors
bin/kamal app logs --since 5m

# Try running console
bin/kamal app exec -i 'bin/rails console'

# Check environment
bin/kamal app exec 'printenv | grep RAILS'
```

### Health check fails
```bash
# Check if app is running
bin/kamal app details

# Check health endpoint manually
bin/kamal app exec 'curl localhost:3000/up'

# Check for binding issues
bin/kamal app exec 'netstat -tlnp'
```

### Database connection issues
```bash
# Test database connection
bin/kamal app exec 'bin/rails db:version'

# Check DATABASE_URL
bin/kamal app exec 'echo $DATABASE_URL'
```

## Checklist

Before deploying:

- [ ] CI passes
- [ ] Local tests pass
- [ ] Migrations are safe
- [ ] Environment variables set
- [ ] Rollback plan ready
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/deploy-agent.md
git commit -m "feat: add deploy-agent for Kamal deployment"
```

---

### Task 12: Create Mobile SDK Agent

**Files:**
- Create: `.claude/agents/mobile-sdk-agent.md`

- [ ] **Step 1: Write mobile-sdk-agent.md**

```markdown
---
name: mobile-sdk-agent
description: Generates API documentation, Postman collections, and mobile SDKs
---

# Mobile SDK Agent

You generate mobile-friendly API documentation and SDKs.

## Responsibilities

- Generate Postman collections from OpenAPI spec
- Create curl examples for each endpoint
- Generate TypeScript SDK (React Native)
- Generate Swift SDK (iOS)
- Generate Kotlin SDK (Android)

## Output Locations

```
docs/
├── api/
│   ├── postman_collection.json
│   ├── curl_examples.md
│   └── sdk/
│       ├── typescript/
│       │   └── api-client.ts
│       ├── swift/
│       │   └── APIClient.swift
│       └── kotlin/
│           └── ApiClient.kt
```

## Generate Swagger/OpenAPI

```bash
# Generate OpenAPI spec from RSwag specs
bundle exec rake rswag:specs:swaggerize

# Output location
cat swagger/v1/openapi.yaml
```

## Postman Collection Template

```json
{
  "info": {
    "name": "Rocketpass API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{access_token}}",
        "type": "string"
      }
    ]
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000/api/v1"
    },
    {
      "key": "access_token",
      "value": ""
    }
  ],
  "item": [
    {
      "name": "Auth",
      "item": [
        {
          "name": "Sign In",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/auth/sign_in",
            "header": [
              {"key": "Content-Type", "value": "application/json"}
            ],
            "body": {
              "mode": "raw",
              "raw": "{\"email\": \"user@example.com\", \"password\": \"password\"}"
            }
          }
        }
      ]
    },
    {
      "name": "Features",
      "item": [
        {
          "name": "List Features",
          "request": {
            "method": "GET",
            "url": "{{base_url}}/features"
          }
        },
        {
          "name": "Create Feature",
          "request": {
            "method": "POST",
            "url": "{{base_url}}/features",
            "body": {
              "mode": "raw",
              "raw": "{\"feature\": {\"name\": \"New Feature\"}}"
            }
          }
        }
      ]
    }
  ]
}
```

## curl Examples Template

```markdown
# Rocketpass API - curl Examples

## Authentication

### Sign In

```bash
curl -X POST http://localhost:3000/api/v1/auth/sign_in \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password"}'
```

Response:
```json
{
  "data": {
    "access_token": "eyJhbG...",
    "refresh_token": "abc123..."
  }
}
```

### Using Token

```bash
export TOKEN="eyJhbG..."
```

## Features

### List Features

```bash
curl http://localhost:3000/api/v1/features \
  -H "Authorization: Bearer $TOKEN"
```

### Create Feature

```bash
curl -X POST http://localhost:3000/api/v1/features \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": {"name": "New Feature", "description": "Description"}}'
```

### Update Feature

```bash
curl -X PATCH http://localhost:3000/api/v1/features/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"feature": {"name": "Updated Name"}}'
```

### Delete Feature

```bash
curl -X DELETE http://localhost:3000/api/v1/features/1 \
  -H "Authorization: Bearer $TOKEN"
```
```

## TypeScript SDK Template

```typescript
// docs/api/sdk/typescript/api-client.ts

interface ApiConfig {
  baseUrl: string;
  accessToken?: string;
}

interface ApiResponse<T> {
  data: T;
  meta?: {
    page: number;
    items: number;
    total: number;
  };
}

interface Feature {
  id: number;
  name: string;
  description: string;
  status: string;
  created_at: string;
  updated_at: string;
}

class ApiClient {
  private config: ApiConfig;

  constructor(config: ApiConfig) {
    this.config = config;
  }

  setAccessToken(token: string) {
    this.config.accessToken = token;
  }

  private async request<T>(
    method: string,
    path: string,
    body?: object
  ): Promise<T> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (this.config.accessToken) {
      headers['Authorization'] = `Bearer ${this.config.accessToken}`;
    }

    const response = await fetch(`${this.config.baseUrl}${path}`, {
      method,
      headers,
      body: body ? JSON.stringify(body) : undefined,
    });

    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.error || 'API request failed');
    }

    return response.json();
  }

  // Auth
  async signIn(email: string, password: string) {
    const response = await this.request<{ data: { access_token: string } }>(
      'POST',
      '/auth/sign_in',
      { email, password }
    );
    this.setAccessToken(response.data.access_token);
    return response;
  }

  // Features
  async getFeatures(page = 1, perPage = 20) {
    return this.request<ApiResponse<Feature[]>>(
      'GET',
      `/features?page=${page}&per_page=${perPage}`
    );
  }

  async getFeature(id: number) {
    return this.request<ApiResponse<Feature>>('GET', `/features/${id}`);
  }

  async createFeature(data: Partial<Feature>) {
    return this.request<ApiResponse<Feature>>('POST', '/features', {
      feature: data,
    });
  }

  async updateFeature(id: number, data: Partial<Feature>) {
    return this.request<ApiResponse<Feature>>('PATCH', `/features/${id}`, {
      feature: data,
    });
  }

  async deleteFeature(id: number) {
    return this.request<void>('DELETE', `/features/${id}`);
  }
}

export { ApiClient, ApiConfig, Feature, ApiResponse };
```

## Generation Script

```bash
#!/bin/bash
# scripts/generate_api_docs.sh

set -e

echo "Generating OpenAPI spec..."
bundle exec rake rswag:specs:swaggerize

echo "Creating docs directory..."
mkdir -p docs/api/sdk/{typescript,swift,kotlin}

echo "Generating Postman collection..."
# Use openapi-to-postman or similar tool
npx openapi-to-postmanv2 -s swagger/v1/openapi.yaml -o docs/api/postman_collection.json

echo "API documentation generated!"
echo "- OpenAPI: swagger/v1/openapi.yaml"
echo "- Postman: docs/api/postman_collection.json"
echo "- curl examples: docs/api/curl_examples.md"
```

## Checklist

Before completing:

- [ ] OpenAPI spec is up to date
- [ ] Postman collection covers all endpoints
- [ ] curl examples are tested
- [ ] TypeScript SDK compiles
- [ ] All authentication flows documented
```

- [ ] **Step 2: Commit**

```bash
git add .claude/agents/mobile-sdk-agent.md
git commit -m "feat: add mobile-sdk-agent for API documentation and SDK generation"
```

---

## Phase 5: CI/CD & Documentation

### Task 13: Update CI Workflow

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Read current ci.yml**

```bash
cat .github/workflows/ci.yml
```

- [ ] **Step 2: Update ci.yml with RSpec and enhanced checks**

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Lint code for consistent style
        run: bundle exec rubocop -f github

  security:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Security scan with Brakeman
        run: bundle exec brakeman --no-pager

      - name: Audit dependencies
        run: bundle exec bundler-audit check --update
        continue-on-error: true

  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: rocketpass_test
        ports:
          - 5432:5432
        options: >-
          --health-cmd="pg_isready"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

      redis:
        image: redis:7
        ports:
          - 6379:6379
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
      - name: Install packages
        run: sudo apt-get update && sudo apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config

      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Setup database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/rocketpass_test
          REDIS_URL: redis://localhost:6379/0
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load

      - name: Run RSpec tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/rocketpass_test
          REDIS_URL: redis://localhost:6379/0
        run: bundle exec rspec --format documentation --format RspecJunitFormatter --out tmp/rspec_results.xml

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: rspec-results
          path: tmp/rspec_results.xml

      - name: Upload coverage report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage-report
          path: coverage/
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci: enhance CI workflow with RSpec, Redis, and coverage"
```

---

### Task 14: Create Deploy Workflow

**Files:**
- Create: `.github/workflows/deploy.yml`

- [ ] **Step 1: Write deploy.yml**

```yaml
name: Deploy

on:
  push:
    branches: [main]
  workflow_dispatch:

concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Install Kamal
        run: gem install kamal

      - name: Set up SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.KAMAL_SSH_PRIVATE_KEY }}

      - name: Deploy with Kamal
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          REDIS_URL: ${{ secrets.REDIS_URL }}
          SENTRY_DSN: ${{ secrets.SENTRY_DSN }}
        run: bin/kamal deploy

      - name: Health check
        run: |
          sleep 30
          curl -f ${{ secrets.APP_URL }}/up || exit 1

      - name: Notify on failure
        if: failure()
        run: echo "Deployment failed! Check logs."
```

- [ ] **Step 2: Commit**

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: add auto-deploy workflow for main branch"
```

---

### Task 15: Update README with Agent Guide

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README structure**

```bash
head -100 README.md
```

- [ ] **Step 2: Add Claude Code Agents section to README**

Add this section after the existing content:

```markdown
## Claude Code Agents

This project includes specialized Claude Code agents for rapid development.

### Available Agents

| Agent | Purpose | Usage |
|-------|---------|-------|
| `product-agent` | Orchestrator for feature requests | `@product-agent add user profiles` |
| `model-agent` | Database models, migrations | `@model-agent create Comment model` |
| `api-agent` | Controllers, services, serializers | `@api-agent create comments endpoint` |
| `ui-agent` | Hotwire views, Stimulus | `@ui-agent create comment form` |
| `test-agent` | RSpec test generation | `@test-agent write specs for comments` |
| `job-agent` | Sidekiq workers | `@job-agent create notification worker` |
| `mobile-sdk-agent` | API docs, SDKs | `@mobile-sdk-agent update postman collection` |
| `review-agent` | Code quality checks | `@review-agent check my changes` |
| `deploy-agent` | Deployment operations | `@deploy-agent deploy to production` |

### Development Workflow

This project follows a TDD-first development workflow:

1. **Plan** - Understand requirements
2. **TDD** - Write failing tests first
3. **Implement** - Write minimal code to pass tests
4. **Quality** - Run rubocop, brakeman, rspec
5. **Review** - Self-review with checklist
6. **PR** - Create PR, wait for CI

See `.claude/workflows/development-workflow.md` for details.

### Quick Start with Agents

```bash
# Start a new feature
@product-agent add user notifications feature

# The product-agent will:
# 1. Create a plan
# 2. Delegate to test-agent (TDD first)
# 3. Delegate to model-agent
# 4. Delegate to api-agent
# 5. Delegate to review-agent
```

### Project Rules

All agents follow the rules in `.claude/CLAUDE.md`:

- Service layer pattern (no business logic in controllers)
- ActsAsTenant for multi-tenancy
- Blueprinter for serialization
- TDD required (tests before implementation)
- Quality gates must pass before PR

### Agent Files

```
.claude/
├── CLAUDE.md                    # Project rules
├── agents/
│   ├── product-agent.md         # Orchestrator
│   ├── model-agent.md           # Database
│   ├── api-agent.md             # API layer
│   ├── ui-agent.md              # Frontend
│   ├── test-agent.md            # Testing
│   ├── job-agent.md             # Background jobs
│   ├── mobile-sdk-agent.md      # Mobile SDKs
│   ├── review-agent.md          # Quality
│   └── deploy-agent.md          # Deployment
└── workflows/
    └── development-workflow.md  # TDD process
```
```

- [ ] **Step 3: Verify README is valid markdown**

```bash
# Check line count increased
wc -l README.md
```

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add Claude Code agents guide to README"
```

---

## Final Verification

### Task 16: Run Quality Checks

- [ ] **Step 1: Verify all files created**

```bash
find .claude -type f -name "*.md" | sort
```

Expected output:
```
.claude/CLAUDE.md
.claude/agents/api-agent.md
.claude/agents/deploy-agent.md
.claude/agents/job-agent.md
.claude/agents/mobile-sdk-agent.md
.claude/agents/model-agent.md
.claude/agents/product-agent.md
.claude/agents/review-agent.md
.claude/agents/test-agent.md
.claude/agents/ui-agent.md
.claude/workflows/development-workflow.md
```

- [ ] **Step 2: Verify workflow files**

```bash
ls -la .github/workflows/
```

Expected: ci.yml and deploy.yml

- [ ] **Step 3: Run existing tests to ensure no regressions**

```bash
bundle exec rspec
```

Expected: All tests pass

- [ ] **Step 4: Run quality checks**

```bash
bundle exec rubocop && bundle exec brakeman --no-pager
```

Expected: No offenses, no warnings

- [ ] **Step 5: Final commit**

```bash
git add -A
git status
```

If any unstaged changes remain, commit them:

```bash
git commit -m "chore: final cleanup for Claude Code agents implementation"
```

---

## Summary

This implementation creates:

- **9 specialized agents** for different development tasks
- **1 development workflow** defining TDD-first process
- **Enhanced CI pipeline** with RSpec, Redis, and coverage
- **Auto-deploy workflow** for main branch
- **Updated README** with agent documentation

Total: 16 tasks across 5 phases
