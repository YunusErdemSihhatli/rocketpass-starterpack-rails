require 'swagger_helper'

RSpec.describe 'Uploads API', swagger_doc: 'v1/openapi.yaml', type: :request do
  path '/api/v1/uploads/presign' do
    post 'S3 direct upload için imzalı URL üret' do
      tags 'Uploads'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[filename content_type byte_size checksum],
        properties: {
          filename: { type: :string },
          content_type: { type: :string },
          byte_size: { type: :integer },
          checksum: { type: :string }
        }
      }

      response '200', 'İmzalı URL ve headers' do
        # run_test!
      end
    end
  end

  path '/api/v1/profiles/{id}/avatar/attach' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Direct upload ile yüklenen avatarı iliştir' do
      tags 'Uploads'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[signed_id],
        properties: {
          signed_id: { type: :string }
        }
      }

      response '200', 'Avatar iliştirildi' do
        # run_test!
      end
    end
  end

  path '/api/v1/tasks/{id}/attachments/attach' do
    parameter name: :id, in: :path, type: :integer, required: true

    post 'Direct upload ile yüklenen ekleri iliştir' do
      tags 'Uploads'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[signed_ids],
        properties: {
          signed_ids: { type: :array, items: { type: :string } }
        }
      }

      response '200', 'Eklendi' do
        # run_test!
      end
    end
  end
end

