module Service
  class Result
    attr_reader :value, :error, :code, :details

    def initialize(success:, value: nil, error: nil, code: nil, details: nil)
      @success = success
      @value = value
      @error = error
      @code = code
      @details = details
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def self.success(value = nil, **meta)
      new(success: true, value: value, **meta)
    end

    def self.failure(error, code: :unprocessable_entity, details: nil, **meta)
      new(success: false, error: error, code: code, details: details, **meta)
    end
  end
end

