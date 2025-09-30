class TaskProcessWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default

  def perform(task_id)
    task = Task.find_by(id: task_id)
    return unless task

    # Start processing
    task.start! if task.may_start?
    # Simulate work
    # ... put your heavy logic here ...
    task.complete! if task.may_complete?
  rescue StandardError => e
    task.fail! if task && task.may_fail?
    Rails.logger.error("TaskProcessWorker error: #{e.message}")
  end
end

