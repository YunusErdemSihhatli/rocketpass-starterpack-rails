module Resources
  class CreateService < ApplicationService
    def initialize(record:)
      @record = record
    end

    def call
      if @record.save
        success(@record)
      else
        failure(@record.errors.full_messages)
      end
    end
  end
end

