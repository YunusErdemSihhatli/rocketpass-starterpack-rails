require 'swagger_helper'

RSpec.describe 'Profiles API', swagger_doc: 'v1/openapi.yaml', type: :request do
  path '/api/v1/profiles' do
    get 'Profil listesi' do
      tags 'Profiles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :items, in: :query, schema: { type: :integer }
      parameter name: :q, in: :query, schema: { type: :object }
      parameter name: :search, in: :query, schema: { type: :string }

      response '200', 'Başarılı' do
        # run_test!
      end
    end

    post 'Profil oluştur' do
      tags 'Profiles'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          profile: { '$ref' => '#/components/schemas/ProfileInput' }
        }
      }

      response '201', 'Oluşturuldu' do
        # run_test!
      end
    end
  end

  path '/api/v1/profiles/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Profil detay' do
      tags 'Profiles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'Başarılı' do
        # run_test!
      end
    end

    put 'Profil güncelle' do
      tags 'Profiles'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          profile: { '$ref' => '#/components/schemas/ProfileInput' }
        }
      }

      response '200', 'Güncellendi' do
        # run_test!
      end
    end

    delete 'Profil sil' do
      tags 'Profiles'
      security [ bearerAuth: [] ]

      response '204', 'Silindi' do
        # run_test!
      end
    end
  end
end

