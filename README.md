# Rocketpass Starterpack Rails

Hızlı başlangıç için kimlik doğrulama (Devise + JWT), roller/izinler, multi-tenancy (ActsAsTenant), admin panel (Administrate), davet (devise_invitable) ve API dokümantasyonu (RSwag) içerir.

## Kurulum

1) Bundler sürümü (lokalde): `gem install bundler:2.5.16`
2) Bağımlılıklar: `bundle install`
3) Veritabanı: `bin/rails db:create db:migrate db:seed`
4) Sunucu: `bin/rails s`

- Admin kullanıcı: `admin@example.com` / `password123`
- Admin panel: `/admin`

## API

- JWT tabanlı auth uçları: `/api/v1/auth`, `/api/v1/auth/sign_in`, `/api/v1/auth/sign_out`, `/api/v1/auth/refresh`, `/api/v1/me`
- Bearer token: `Authorization: Bearer <access_token>`

## API Dokümantasyonu (Swagger / RSwag)

- UI: `http://localhost:3000/api-docs`
- Kaynak dosya: `swagger/v1/openapi.yaml`

### RSpec + rswag-specs ile üretim

- Testleri çalıştır: `bundle exec rspec`
- Swagger dosyasını üret: `bundle exec rake rswag:specs:swaggerize`
  - Çıktı: `swagger/v1/openapi.yaml` (UI bu dosyayı servis eder)

Endpoint’ler ve şemalar `spec/requests/api/v1/auth_spec.rb` altında rswag DSL ile tanımlıdır. Gerekirse `run_test!` çağrıları aktif edilerek gerçek istek/yanıt doğrulaması yapılabilir.

## Docker ile Hızlı Başlangıç

Önkoşul: Docker ve Docker Compose kurulu olmalı.

1) `.env` dosyanı hazırla (opsiyonel ama önerilir)
   - `cp .env.example .env`
   - `RAILS_MASTER_KEY` değerini `config/master.key` içeriğinden kopyalayın veya `export RAILS_MASTER_KEY=$(cat config/master.key)`
2) Docker servislerini başlat
   - `docker compose build`
   - `docker compose up -d`
3) Veritabanını hazırla (ilk kurulumda)
   - `docker compose run --rm web bin/rails db:prepare`
4) Uygulama adresleri
   - API/UI: `http://localhost:3000`
   - Swagger UI: `http://localhost:3000/api-docs`
   - Sidekiq UI: `http://localhost:3000/admin/sidekiq` (admin kullanıcı ile giriş gerekir)

Notlar:
- Bu compose dosyası varsayılan olarak uygulamayı production modunda çalıştırır (Dockerfile üretim odaklıdır). Geliştirmede isterseniz `RAILS_ENV=development` vererek geliştirme modunda çalıştırabilirsiniz.
- Active Storage için local storage varsayılandır. S3 kullanmak için `config/environments/production.rb` altında servisi `:amazon` yapıp gerekli AWS ENV değişkenlerini `.env` dosyanıza ekleyin.
- Postgres ve Redis, `docker-compose.yml` ile birlikte ayağa kalkar.

## Kullanılan Gem'ler (Özet)

- Devise: Kimlik doğrulama, `devise-jwt` ile JWT, `devise_invitable` ile davet.
- Pundit: Policy tabanlı yetkilendirme.
- Rolify + Permission modeli: Esnek rol/izin.
- ActsAsTenant: Account bazlı multi-tenancy.
- Administrate: Admin panel.
- Blueprinter: JSON serileştirme (Blueprint pattern).
- RSwag (api/ui/specs): Swagger/OpenAPI dokümantasyonu ve UI.
- Doorkeeper: OAuth2 provider (password flow dahil).
- Rack CORS: Frontend/mobil client CORS desteği.
- Pagy: Sayfalama (hafif ve hızlı).
- Ransack: Filtreleme/sıralama DSL’i.
- pg_search: Postgres full-text search.
- Sidekiq + sidekiq-scheduler + Redis: Arka plan işler ve cron.
- AASM: State machine (örn. Task lifecycle).
- Active Storage + validations + image_processing + aws-sdk-s3: Dosya yükleme, doğrulama, resim işleme, S3.
- RSpec + rswag-specs: Test + API doc üretimi.
- Debug ve DX: pry-rails, awesome_print, dotenv-rails.
- Güvenlik ve stil: brakeman, rubocop-rails-omakase, rubocop-rails.

Geliştirmede kolaylık için örnek `.env` dosyası: `.env.example` (kopyalayıp `.env` yapın ve değerleri doldurun).
# rocketpass-starterpack-rails
