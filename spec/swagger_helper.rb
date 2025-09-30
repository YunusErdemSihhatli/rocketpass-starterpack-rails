require 'rails_helper'

RSpec.configure do |config|
  config.swagger_root = Rails.root.join('swagger').to_s

  config.swagger_docs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.3',
      info: {
        title: 'Rocketpass API',
        version: 'v1',
        description: 'JWT tabanlı kimlik doğrulama, davet, rol ve yetki.'
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Development' }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT'
          }
        },
        schemas: {
          AuthTokens: {
            type: :object,
            properties: {
              message: { type: :string },
              user: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  email: { type: :string, format: :email }
                }
              },
              access_token: { type: :string },
              refresh_token: { type: :string },
              token_type: { type: :string, example: 'Bearer' },
              expires_in: { type: :integer, example: 900 }
            }
          },
          RefreshResponse: {
            type: :object,
            properties: {
              access_token: { type: :string },
              refresh_token: { type: :string },
              token_type: { type: :string, example: 'Bearer' },
              expires_in: { type: :integer, example: 900 }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

