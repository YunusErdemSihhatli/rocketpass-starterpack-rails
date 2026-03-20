if defined?(Rswag::Api)
  Rswag::Api.configure do |c|
    c.swagger_root = Rails.root.join("swagger").to_s
  end
end
