source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.3"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

# Authentication, authorization, tenancy, and admin panel
gem "devise"
gem "rolify"
gem "pundit"
gem "acts_as_tenant"
gem "administrate"
gem "devise_invitable", "~> 2.0"
gem "devise-jwt", "~> 0.12"
gem "blueprinter"
gem "doorkeeper"
gem "rack-cors"
gem "pagy"
gem "ransack"
gem "pg_search"
gem "sidekiq"
gem "sidekiq-scheduler"
gem "redis"
gem "aasm"
gem "active_storage_validations"
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3", "~> 1"

group :development do
  gem "rswag-api"
  gem "rswag-ui"
end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Testing and API docs
  gem "rspec-rails", "~> 8.0"
  gem "rswag-specs"
  gem "pry-rails"
  gem "awesome_print"
  gem "dotenv-rails"
  gem "rubocop-rails", require: false
end
