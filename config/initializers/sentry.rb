return unless ENV["SENTRY_DSN"].present?

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
  config.enabled_environments = %w[staging production]
  config.environment = Rails.env
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f
  config.send_default_pii = false
end
