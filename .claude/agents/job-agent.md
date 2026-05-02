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
