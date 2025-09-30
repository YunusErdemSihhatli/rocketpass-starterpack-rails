class CleanupFailedTasksWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low

  def perform
    Task.where('state = ? AND updated_at < ?', 'failed', 7.days.ago).find_each do |task|
      task.destroy
    end
  end
end

