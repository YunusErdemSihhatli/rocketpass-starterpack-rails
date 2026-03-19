# Rocketpass Starterpack Rails

Rails API or full-stack products rarely fail because of missing models. They fail because the boring foundation is missing. This starter focuses on that foundation first: testability, deployability, observability, and a clean day-1 developer experience.

Included by default:
- GitHub Actions for CI
- Kamal for low-cost deploys to a VPS
- Sentry for production error monitoring
- Structured JSON logging to STDOUT
- RSpec, SimpleCov, Brakeman, and RuboCop
- Sidekiq + Redis for background jobs

## Quick Start

1. Install dependencies:
   ```bash
   bundle install
   ```
2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```
3. Prepare the database:
   ```bash
   bin/setup --skip-server
   ```
4. Start the app and worker:
   ```bash
   bin/dev
   ```

Useful URLs:
- App: `http://localhost:3000`
- Swagger UI: `http://localhost:3000/api-docs`
- Health check: `http://localhost:3000/up`
- Sidekiq Web: `http://localhost:3000/admin/sidekiq`

## What This Starter Solves First

### Test
- `bundle exec rspec`
- `bundle exec rubocop`
- `bundle exec brakeman --no-pager`
- `bin/ci`

CI runs these checks automatically on pull requests and on pushes to `main`.

### Monitoring
- `Sentry` is wired for `staging` and `production`
- Set `SENTRY_DSN` and production exceptions will be reported automatically
- Health checks are available at `/up`

### Logging
- Production logs are emitted as JSON to STDOUT
- This works well with Docker, Kamal, Fly logs, Render logs, Railway logs, or any VPS log shipper
- Request IDs are preserved through Rails log tags

### Deploy
- `config/deploy.yml` is set up for `Kamal`
- Default recommendation: one cheap VPS, managed Postgres, managed Redis
- Web and Sidekiq worker roles are split in the deploy config

### CI/CD
- `.github/workflows/ci.yml` runs lint, security scanning, and RSpec
- `.github/workflows/deploy.yml` deploys on `main` or manual dispatch when secrets exist

## Local Development

This project uses `Procfile.dev` so web and Sidekiq start together.

```bash
bin/dev
```

If you prefer Docker for local dependencies:

```bash
docker compose up -d db redis
bin/setup --skip-server
bin/dev
```

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

Use [`.env.example`](/Users/yunuserdemsihhatli/projects/rails/rocketpass-starterpack-rails/.env.example) as the source of truth for local setup. Use [`.env`](/Users/yunuserdemsihhatli/projects/rails/rocketpass-starterpack-rails/.env) for local development only. For deploys, the same values should be provided through Kamal secrets and GitHub repository secrets instead of committing them.

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

[`config/database.yml`](/Users/yunuserdemsihhatli/projects/rails/rocketpass-starterpack-rails/config/database.yml) is now env-first and supports these environments directly:
- `development`
- `test`
- `staging`
- `production`

Priority order is:
1. environment-specific `*_DATABASE_URL`
2. shared `DATABASE_URL`
3. shared host/port/user/pass plus per-environment DB name

This keeps local setup simple while still supporting managed databases in staging and production.

## Recommended Cheap Production Setup

The lowest-friction setup for a new project is:
- 1 VPS for app + Sidekiq
- managed Postgres
- managed Redis
- GHCR as image registry
- GitHub Actions for CI/CD
- Sentry for errors and traces

That keeps infra cost and operational burden low without locking the project into a full PaaS.

## Existing Product Features

The starter still includes the app-layer building blocks already present in this repository:
- Devise + JWT authentication
- invitations with `devise_invitable`
- Pundit authorization
- ActsAsTenant multi-tenancy
- Administrate admin panel
- Blueprinter serialization
- Doorkeeper OAuth
- Pagy, Ransack, pg_search
- Active Storage and S3 support

## SaaS Role Model

This starter now uses a tenant-first authorization approach.

Rules:
- `Account` is the tenant boundary
- `acts_as_tenant` scopes tenant users by `current_account`
- `superadmin` is a global role and is never tenant-owned
- `admin` is tenant-owned and only works inside its own account
- custom roles and permissions are tenant-owned

Current behavior:
- `superadmin`: can access all accounts, users, roles, permissions, and admin resources
- `admin`: can manage users, roles, permissions, and tenant data only inside their own account
- tenant-defined roles: cannot escape their own account
- reserved `superadmin` role: cannot be edited or destroyed from the admin panel

Implementation notes:
- `Account` is the business equivalent of `Company` in this codebase
- roles and permissions are account-aware
- policy scopes default to the signed-in user's account
- `superadmin` bypasses tenant scoping
- admin panel queries are tenant-scoped unless the signed-in user is `superadmin`

Seed users:
- `superadmin@example.com` / `password123`
- `admin@example.com` / `password123`

## Starter Principle

This repository should let someone clone it, configure a few secrets, and get all of this from day one:
- code quality checks
- automated tests
- health checks
- production error monitoring
- structured logs
- repeatable deploys

That is the baseline. Extra architecture layers should come after that, not before.
