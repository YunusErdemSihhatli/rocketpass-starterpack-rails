class ApplicationService
  def self.call(*args, **kwargs, &block)
    new(*args, **kwargs).call(&block)
  end

  private

  def success(value = nil, **meta)
    Service::Result.success(value, **meta)
  end

  def failure(error, code: :unprocessable_entity, details: nil, **meta)
    Service::Result.failure(error, code: code, details: details, **meta)
  end
end

