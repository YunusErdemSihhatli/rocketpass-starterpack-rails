module Resources
  class DestroyService < ApplicationService
    def initialize(record:)
      @record = record
    end

    def call
      @record.destroy
      success(nil)
    end
  end
end

