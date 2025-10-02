module Resources
  class UpdateService < ApplicationService
    def initialize(record:, attributes: {})
      @record = record
      @attributes = attributes
    end

    def call
      if @record.update(@attributes)
        success(@record)
      else
        failure(@record.errors.full_messages)
      end
    end
  end
end

