require 'sidekiq'
require 'sidekiq-scheduler'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  schedule_file = Rails.root.join('config', 'sidekiq.yml')
  if File.exist?(schedule_file)
    schedule = YAML.load_file(schedule_file).fetch('schedule', {})
    if schedule.any?
      Sidekiq::Scheduler.dynamic = true
      Sidekiq.schedule = schedule
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

