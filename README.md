# Rocketpass Starterpack Rails

Rails API or full-stack products rarely fail because of missing models. They fail because the boring foundation is missing. This starter combines that operational foundation with the application-layer building blocks already present in the repo.

Included by default:
- Devise + JWT authentication
- invitations with `devise_invitable`
- Pundit authorization
- ActsAsTenant multi-tenancy
- Administrate admin panel
- Blueprinter serialization
- Doorkeeper OAuth
- Pagy, Ransack, pg_search
- Active Storage and S3 support
- RSwag API documentation
- Sidekiq + Redis for background jobs
- GitHub Actions for CI
- Kamal for low-cost deploys to a VPS
- Sentry for production error monitoring
- Structured JSON logging to STDOUT
- RSpec, SimpleCov, Brakeman, and RuboCop

## Quick Start

1. Install the expected Bundler version if needed:
   ```bash
   gem install bundler:2.5.16
   ```
2. Install dependencies:
   ```bash
   bundle install
   ```
3. Copy environment variables:
   ```bash
   cp .env.example .env
   ```
4. Prepare the database:
   ```bash
   bin/setup --skip-server
   ```
5. Start the app and worker:
   ```bash
   bin/dev
   ```

Useful URLs:
- App: `http://localhost:3000`
- Swagger UI: `http://localhost:3000/api-docs`
- Health check: `http://localhost:3000/up`
- Admin panel: `http://localhost:3000/admin`
- Sidekiq Web: `http://localhost:3000/admin/sidekiq`

Seed users:
- `superadmin@example.com` / `password123`
- `admin@example.com` / `password123`

If you prefer the explicit Rails setup flow instead of `bin/setup`, this also works:
```bash
bin/rails db:create db:migrate db:seed
bin/rails s
```

## API

JWT-based auth endpoints:
- `/api/v1/auth`
- `/api/v1/auth/sign_in`
- `/api/v1/auth/sign_out`
- `/api/v1/auth/refresh`
- `/api/v1/me`

Use bearer tokens with:
```text
Authorization: Bearer <access_token>
```

## API Documentation

- UI: `http://localhost:3000/api-docs`
- Generated file: `swagger/v1/openapi.yaml`

Generated with RSpec + `rswag-specs`:
- Run tests: `bundle exec rspec`
- Generate Swagger file: `bundle exec rake rswag:specs:swaggerize`

Endpoints and schemas are defined in request specs such as `spec/requests/api/v1/auth_spec.rb` and `spec/requests/api/v1/profiles_spec.rb` using the RSwag DSL. Where needed, `run_test!` can be enabled to validate real request/response flows.

## Service Layer

This starter includes a lightweight, explicit service layer to encapsulate business logic and keep controllers and models lean.

- Location: `app/services`
- Base class: `ApplicationService` with `.call`, `success`, and `failure` helpers
- Result object: `Service::Result` with `success?`, `value`, `error`, and `code`
- Generic CRUD services used by API `ResourceController`:
  - `Resources::CreateService`
  - `Resources::UpdateService`
  - `Resources::DestroyService`
- Sample domain services:
  - `Profiles::UpdateAvatarService`
  - `Users::InviteService`

`Api::V1::ResourceController` delegates `create`, `update`, and `destroy` to services and maps failures through the shared result object.

Example:
```ruby
result = Resources::CreateService.call(record: profile)

if result.success?
  result.value
else
  result.error
end
```

## Internationalization (I18n)

Multi-language support is enabled for both API and web.

- Available locales: `:en`, `:tr`
- Default locale: `:en`
- API locale source: `X-Locale` header or `?locale=` param in `Api::V1::BaseController`
- Web locale source: the same logic in `ApplicationController`
- Translation files:
  - `config/locales/en.yml`
  - `config/locales/tr.yml`

Services use I18n for error messages where applicable. Send `X-Locale: tr` to receive Turkish responses when translations exist. Unsupported or missing locales fall back to English.

## SaaS Role Model

This starter uses a tenant-first authorization approach.

Rules:
- `Account` is the tenant boundary
- `acts_as_tenant` scopes tenant users by `current_account`
- `superadmin` is global and is never tenant-owned
- `admin` is tenant-owned and only works inside its own account
- custom roles and permissions are tenant-owned

Current behavior:
- `superadmin` can access all accounts, users, roles, permissions, and admin resources
- `admin` can manage users, roles, permissions, and tenant data only inside its own account
- tenant-defined roles cannot escape their own account
- the reserved `superadmin` role cannot be edited or destroyed from the admin panel

Implementation notes:
- `Account` is the business equivalent of `Company` in this codebase
- roles and permissions are account-aware
- policy scopes default to the signed-in user's account
- `superadmin` bypasses tenant scoping
- admin panel queries are tenant-scoped unless the signed-in user is `superadmin`

## What This Starter Solves First

### Test

- `bundle exec rspec`
- `bundle exec rubocop`
- `bundle exec brakeman --no-pager`
- `bin/ci`

CI runs these checks automatically on pull requests and on pushes to `main`.

### Monitoring

- `Sentry` is wired for `staging` and `production`
- set `SENTRY_DSN` and production exceptions will be reported automatically
- health checks are available at `/up`

### Logging

- production logs are emitted as JSON to STDOUT
- this works well with Docker, Kamal, Fly logs, Render logs, Railway logs, or any VPS log shipper
- request IDs are preserved through Rails log tags

### Deploy

- `config/deploy.yml` is set up for `Kamal`
- default recommendation: one cheap VPS, managed Postgres, managed Redis
- web and Sidekiq worker roles are split in the deploy config

### CI/CD

- `.github/workflows/ci.yml` runs lint, security scanning, and RSpec
- `.github/workflows/deploy.yml` deploys on `main` or manual dispatch when secrets exist

## Local Development

This project uses `Procfile.dev` so web and Sidekiq start together:

```bash
bin/dev
```

If you prefer Docker only for local dependencies:

```bash
docker compose up -d db redis
bin/setup --skip-server
bin/dev
```

## Quick Start With Docker

Prerequisites: Docker and Docker Compose installed.

1. Prepare your `.env` file:
   ```bash
   cp .env.example .env
   export RAILS_MASTER_KEY=$(cat config/master.key)
   ```
2. Build and start services:
   ```bash
   docker compose build
   docker compose up -d
   ```
3. Prepare the database on first setup:
   ```bash
   docker compose run --rm web bin/rails db:prepare
   ```

Docker URLs:
- App: `http://localhost:3000`
- Swagger UI: `http://localhost:3000/api-docs`
- Sidekiq UI: `http://localhost:3000/admin/sidekiq`

Notes:
- the compose setup runs the app in production mode by default because the Dockerfile is production-ready
- for development in Docker, set `RAILS_ENV=development`
- Active Storage defaults to local storage
- to use S3, switch the service to `:amazon` in `config/environments/production.rb` and set the AWS env vars
- Postgres and Redis are provisioned through `docker-compose.yml`

## Deployment With Kamal

1. Edit `config/deploy.yml`
   - set your image name
   - set your server IP
   - set your production host
2. Export deploy secrets:
   ```bash
   export KAMAL_REGISTRY_PASSWORD=...
   export DATABASE_URL=...
   export REDIS_URL=...
   export SENTRY_DSN=...
   export RAILS_MASTER_KEY=$(cat config/master.key)
   ```
3. Boot the server:
   ```bash
   bin/kamal setup
   ```
4. Deploy:
   ```bash
   bin/kamal deploy
   ```

For GitHub Actions deploys, define these repository secrets:
- `KAMAL_SSH_PRIVATE_KEY`
- `KAMAL_REGISTRY_PASSWORD`
- `RAILS_MASTER_KEY`
- `DATABASE_URL`
- `REDIS_URL`
- `SENTRY_DSN`

## Environment And Secrets

Use `.env.example` as the source of truth for local setup. Use `.env` for local development only. For deploys, provide the same values through Kamal secrets and GitHub repository secrets instead of committing them.

| Variable | Local `.env` | GitHub Actions Secret | Kamal / Server Env | Purpose |
| --- | --- | --- | --- | --- |
| `RAILS_MASTER_KEY` | optional locally | required | required | decrypt Rails credentials in staging and production |
| `KAMAL_REGISTRY_PASSWORD` | optional locally | required | required | authenticate to container registry |
| `DATABASE_URL` | optional | required for deploy | recommended | shared database URL fallback |
| `DEVELOPMENT_DATABASE_URL` | optional | no | no | explicit development DB URL |
| `TEST_DATABASE_URL` | optional | no | no | explicit test DB URL |
| `STAGING_DATABASE_URL` | optional | optional | recommended | staging database connection |
| `PRODUCTION_DATABASE_URL` | optional | optional | recommended | production database connection |
| `PRODUCTION_CABLE_DATABASE_URL` | optional | optional | optional | separate Action Cable DB if needed |
| `REDIS_URL` | yes | required for deploy | required | Sidekiq and cache Redis connection |
| `SENTRY_DSN` | optional | recommended | recommended | monitoring and error tracking |
| `SENTRY_TRACES_SAMPLE_RATE` | optional | optional | optional | Sentry performance sampling |
| `APP_HOST` | yes | optional | required | public app host for links and deploy config |
| `HOST` | yes | no | no | local bind host |
| `PORT` | yes | no | no | local app port |
| `RAILS_LOG_LEVEL` | yes | optional | optional | app log verbosity |
| `RAILS_MAX_THREADS` | yes | optional | optional | Puma/Rails concurrency |
| `DB_POOL` | yes | optional | optional | Active Record connection pool |
| `DB_HOST` | yes | no | optional | shared DB host when URL is not used |
| `DB_PORT` | yes | no | optional | shared DB port when URL is not used |
| `DB_USERNAME` | yes | no | optional | shared DB username when URL is not used |
| `DB_PASSWORD` | yes | no | optional | shared DB password when URL is not used |
| `DEVELOPMENT_DB_NAME` | yes | no | no | development DB name fallback |
| `TEST_DB_NAME` | yes | no | no | test DB name fallback |
| `STAGING_DB_NAME` | optional | no | optional | staging DB name fallback |
| `PRODUCTION_DB_NAME` | optional | no | optional | production DB name fallback |
| `PRODUCTION_CABLE_DB_NAME` | optional | no | optional | production cable DB name fallback |
| `AWS_ACCESS_KEY_ID` | optional | optional | optional | S3 uploads |
| `AWS_SECRET_ACCESS_KEY` | optional | optional | optional | S3 uploads |
| `AWS_REGION` | optional | optional | optional | S3 region |
| `AWS_S3_BUCKET` | optional | optional | optional | S3 bucket name |

Recommended rule:
- local development: use `.env`
- CI: use GitHub Actions secrets only where needed
- staging and production: use URL-based database config and injected secrets
- never commit real secret values

## Database Environments

`config/database.yml` is env-first and supports these environments directly:
- `development`
- `test`
- `staging`
- `production`

Priority order:
1. environment-specific `*_DATABASE_URL`
2. shared `DATABASE_URL`
3. shared host/port/user/pass plus per-environment DB name

This keeps local setup simple while still supporting managed databases in staging and production.

## Gems Used (Summary)

- `Devise`: authentication with `devise-jwt` and `devise_invitable`
- `Pundit`: policy-based authorization
- `Rolify + Permission model`: flexible role and permission system
- `ActsAsTenant`: account-based multi-tenancy
- `Administrate`: admin panel
- `Blueprinter`: JSON serialization
- `RSwag`: Swagger/OpenAPI docs and UI
- `Doorkeeper`: OAuth2 provider
- `Rack CORS`: frontend and mobile CORS support
- `Pagy`: pagination
- `Ransack`: filtering and sorting DSL
- `pg_search`: Postgres full-text search
- `Sidekiq + sidekiq-scheduler + Redis`: background jobs and cron
- `AASM`: state machine support
- `Active Storage + validations + image_processing + aws-sdk-s3`: uploads, validation, image processing, and S3
- `RSpec + rswag-specs`: testing and API doc generation
- `pry-rails`, `awesome_print`, `dotenv-rails`: local DX
- `brakeman`, `rubocop-rails-omakase`, `rubocop-rails`: security and style checks

## Recommended Cheap Production Setup

The lowest-friction setup for a new project is:
- 1 VPS for app + Sidekiq
- managed Postgres
- managed Redis
- GHCR as image registry
- GitHub Actions for CI/CD
- Sentry for errors and traces

That keeps infra cost and operational burden low without locking the project into a full PaaS.

## Starter Principle

This repository should let someone clone it, configure a few secrets, and get all of this from day one:
- code quality checks
- automated tests
- health checks
- production error monitoring
- structured logs
- repeatable deploys

That is the baseline. Extra architecture layers should come after that, not before.

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
