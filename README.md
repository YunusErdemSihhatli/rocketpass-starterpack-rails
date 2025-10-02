# Rocketpass Starterpack Rails

Includes authentication (Devise + JWT), roles/permissions, multi-tenancy (ActsAsTenant), admin panel (Administrate), invitations (devise_invitable), and API documentation (RSwag) for a quick start.

## Setup

1. Bundler version (local): `gem install bundler:2.5.16`  
2. Dependencies: `bundle install`  
3. Database: `bin/rails db:create db:migrate db:seed`  
4. Server: `bin/rails s`  

- Admin user: `admin@example.com` / `password123`  
- Admin panel: `/admin`  

## API

- JWT-based auth endpoints:  
  - `/api/v1/auth`  
  - `/api/v1/auth/sign_in`  
  - `/api/v1/auth/sign_out`  
  - `/api/v1/auth/refresh`  
  - `/api/v1/me`  
- Bearer token: `Authorization: Bearer <access_token>`  

## API Documentation (Swagger / RSwag)

- UI: `http://localhost:3000/api-docs`  
- Source file: `swagger/v1/openapi.yaml`  

### Generated with RSpec + rswag-specs

- Run tests: `bundle exec rspec`  
- Generate Swagger file: `bundle exec rake rswag:specs:swaggerize`  
  - Output: `swagger/v1/openapi.yaml` (served by the UI)  

Endpoints and schemas are defined under `spec/requests/api/v1/auth_spec.rb` using the RSwag DSL.  
If needed, `run_test!` calls can be enabled to validate real request/response flows.  

## Quick Start with Docker

**Prerequisites:** Docker and Docker Compose installed.

1. Prepare your `.env` file (optional but recommended)  
   - `cp .env.example .env`  
   - Copy `RAILS_MASTER_KEY` from `config/master.key` or set it with:  
     `export RAILS_MASTER_KEY=$(cat config/master.key)`  
2. Start Docker services  
   - `docker compose build`  
   - `docker compose up -d`  
3. Prepare the database (on first setup)  
   - `docker compose run --rm web bin/rails db:prepare`  
4. Application URLs  
   - API/UI: `http://localhost:3000`  
   - Swagger UI: `http://localhost:3000/api-docs`  
   - Sidekiq UI: `http://localhost:3000/admin/sidekiq` (requires admin login)  

**Notes:**  
- This compose file runs the app in **production mode** by default (Dockerfile is production-ready). For development, run with `RAILS_ENV=development`.  
- Active Storage defaults to **local storage**. To use S3, set the service to `:amazon` in `config/environments/production.rb` and add the required AWS ENV variables to your `.env` file.  
- Postgres and Redis are provisioned via `docker-compose.yml`.  

## Gems Used (Summary)

- **Devise**: Authentication (`devise-jwt` for JWT, `devise_invitable` for invitations).  
- **Pundit**: Policy-based authorization.  
- **Rolify + Permission model**: Flexible role/permission system.  
- **ActsAsTenant**: Account-based multi-tenancy.  
- **Administrate**: Admin panel.  
- **Blueprinter**: JSON serialization (Blueprint pattern).  
- **RSwag (api/ui/specs)**: Swagger/OpenAPI documentation and UI.  
- **Doorkeeper**: OAuth2 provider (including password flow).  
- **Rack CORS**: CORS support for frontend/mobile clients.  
- **Pagy**: Lightweight, fast pagination.  
- **Ransack**: Filtering/sorting DSL.  
- **pg_search**: Postgres full-text search.  
- **Sidekiq + sidekiq-scheduler + Redis**: Background jobs and cron.  
- **AASM**: State machine (e.g., Task lifecycle).  
- **Active Storage + validations + image_processing + aws-sdk-s3**: File upload, validation, image processing, S3.  
- **RSpec + rswag-specs**: Testing + API doc generation.  
- **Debug & DX**: pry-rails, awesome_print, dotenv-rails.  
- **Security & style**: brakeman, rubocop-rails-omakase, rubocop-rails.  

---

For development convenience, an example `.env` file is provided: `.env.example`.  
Copy it to `.env` and fill in the values as needed.  

# rocketpass-starterpack-rails

## Service Layer (English)

This starter now includes a lightweight, explicit service layer to encapsulate business logic and keep controllers/models lean.

- Location: `app/services`
- Base class: `ApplicationService` with `.call`, `success`, and `failure` helpers
- Result object: `Service::Result` providing `success?`, `value`, `error`, `code`
- Generic CRUD services (used by API `ResourceController`):
  - `Resources::CreateService` → persists a new record
  - `Resources::UpdateService` → updates attributes
  - `Resources::DestroyService` → destroys a record
- Sample domain services:
  - `Profiles::UpdateAvatarService` for attach/purge avatar
  - `Users::InviteService` for sending invitations in Admin

API controllers (`Api::V1::ResourceController`) now delegate `create/update/destroy` to services, returning uniform error handling via the result object.

Example usage
```
result = Resources::CreateService.call(record: profile)
if result.success?
  # result.value is the persisted record
else
  # result.error contains messages; result.code for HTTP mapping
end
```

## Internationalization (I18n) (English)

Multi-language support is enabled for API and web.

- Config: `config.i18n.available_locales = %i[en tr]`, `config.i18n.default_locale = :en`
- Locale selection:
  - API: `Api::V1::BaseController` sets locale from `X-Locale` header or `?locale=` param
  - Web: `ApplicationController` applies the same logic
- Translation files:
  - `config/locales/en.yml`
  - `config/locales/tr.yml`
- Services use I18n for error messages (e.g. `Profiles::UpdateAvatarService`, `Users::InviteService`).

Client usage
- Send `X-Locale: tr` to receive Turkish messages where applicable.
- Omit or send an unsupported locale to fall back to English.

Swagger/rswag
- Request specs under `spec/requests/api/v1/profiles_spec.rb` include Authorization and exercise CRUD endpoints, which internally call the service layer.
