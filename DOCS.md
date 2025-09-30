# Rocketpass Starterpack - Teknik Dokümantasyon

Bu proje SaaS başlangıç paketi olarak kimlik doğrulama, yetkilendirme, çoklu kiracı (tenancy), admin panel ve API dokümantasyon altyapılarını içerir.

## Bileşenler ve Gem'ler

- Devise (+ JWT, Invitable): kimlik doğrulama, davet
- Pundit: policy tabanlı yetkilendirme
- Rolify + Permission: esnek rol/izin modeli
- ActsAsTenant: multi-tenancy (Account bazlı)
- Administrate: admin panel
- Blueprinter: hızlı ve güvenli JSON serileştirme
- RSwag (API + UI + Specs): Swagger/OpenAPI dokümantasyonu
- Rack CORS: frontend/mobil istemci erişimi
- Doorkeeper: OAuth2 Provider
- Pagy: pagination
- Ransack: gelişmiş filtreleme
- pg_search: Postgres full-text arama
- Sidekiq: background jobs
- sidekiq-scheduler: cron/schedule jobs
- Redis: Sidekiq ve cache için
- AASM: durum (state) makinesi
- Active Storage: dosya ve medya upload
- active_storage_validations: Active Storage doğrulamaları
- image_processing: resim işleme (mini_magick/vips)
- aws-sdk-s3: S3 storage desteği

## API Mimari

- `Api::V1::BaseController`: auth + tenant bağlama + Pundit
- `Api::V1::ResourceController`: CRUD şablonu
  - `index`: Ransack (`q`), full-text (`search`) ve Pagy ile sayfalama
  - `show`, `create`, `update`, `destroy`
  - `resource_model`, `resource_blueprint` sınıf öznitelikleri ile yapılandırma
  - `resource_params` metodunu child controller tanımlar

Örnek: `ProfilesController` → `resource_model = Profile`, `resource_blueprint = ProfileBlueprint`

## Background Jobs

- Sidekiq Web: `/admin/sidekiq` (admin yetkisi gerekir)
- Konfig: `config/sidekiq.yml`, initializer `config/initializers/sidekiq.rb`
- Örnek işçiler: `TaskProcessWorker`, `CleanupFailedTasksWorker` (scheduler ile günün 03:00'ünde çalışır)

## AASM

- `Task` modeli ile örnek state makinesi: `draft → queued → in_progress → completed` (hata: `failed`)
- Event tetikleme: `POST /api/v1/tasks/{id}/event { event: "queue" }`

## Swagger / OpenAPI

- UI: `/api-docs`
- Şema: `swagger/v1/openapi.yaml`
- RSpec + rswag-specs ile üretim
  - Test: `bundle exec rspec`
  - Swagger yazdır: `bundle exec rake rswag:specs:swaggerize`

## Dosya & Medya Yükleme

- Local storage: `config/storage.yml -> local`
- S3: `config/storage.yml -> amazon` (ENV: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `AWS_S3_BUCKET`)
- Varsayılan service: `config/environments/*.rb` içinde `config.active_storage.service = :local` (veya `:amazon`)

Doğrulamalar
- Profil avatarı: max 5MB, content-type image (png/jpg/jpeg/webp)
- Task ekleri: max 20MB; image/pdf

API Uçları (Uploads)
- `POST /api/v1/profiles/{id}/avatar` (multipart form-data, `file`)
- `DELETE /api/v1/profiles/{id}/avatar`
- `POST /api/v1/tasks/{id}/attachments` (multipart, `files[]`)
- `DELETE /api/v1/tasks/{id}/attachments/{attachment_id}`

Resim İşleme
- `ProfileBlueprint` içinde `avatar_thumb_url` → `resize_to_limit: [200,200]`

## OAuth2 (Doorkeeper)

- Endpointler `/oauth/*` (applications, tokens)
- Resource owner password flow desteklenir (email + password)

## CORS

- `config/initializers/cors.rb` → `origins '*'` (development). Prod’da domain bazlı kısıtlayın.

## Pagination

- Pagy default: sayfa başına 20; metadata JSON’da `meta` altında.

## Arama/Filtreleme

- Ransack: `q` parametresi ile kolon bazlı sorgu
- Full-text: `search` parametresi ile `pg_search` scope’u (`search_text`)

## Genişletme

Yeni bir model için:
1) Model ve migrasyon (mümkünse `account_id` ile `acts_as_tenant :account`)
2) Blueprint (JSON alanları)
3) Controller: `Api::V1::ResourceController`'dan kalıtım, `resource_model`, `resource_blueprint`, `resource_params`
4) Rota: `resources :yeni_kaynak`
5) Swagger: `spec/requests/..._spec.rb` ve/veya `swagger/v1/openapi.yaml`
