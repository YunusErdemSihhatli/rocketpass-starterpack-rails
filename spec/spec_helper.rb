require 'rswag/specs'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.disable_monkey_patching!

  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = ".rspec_status"
end

