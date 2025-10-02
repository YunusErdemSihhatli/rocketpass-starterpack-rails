require 'swagger_helper'

RSpec.describe 'Profiles API', swagger_doc: 'v1/openapi.yaml', type: :request do
  let(:account) { Account.create!(name: 'Acme Inc') }
  let(:current_user) { User.create!(email: 'apiuser@example.com', password: 'password', account: account) }
  let(:member) { User.create!(email: 'member@example.com', password: 'password', account: account) }
  let(:token) do
    Warden::JWTAuth::UserEncoder.new.call(current_user, :user, nil).first
  end
  let(:Authorization) { "Bearer #{token}" }
  path '/api/v1/profiles' do
    get 'Profil listesi' do
      tags 'Profiles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true

      parameter name: :page, in: :query, schema: { type: :integer }
      parameter name: :items, in: :query, schema: { type: :integer }
      parameter name: :q, in: :query, schema: { type: :object }
      parameter name: :search, in: :query, schema: { type: :string }

      response '200', 'Başarılı' do
        run_test!
      end
    end

    post 'Profil oluştur' do
      tags 'Profiles'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          profile: { '$ref' => '#/components/schemas/ProfileInput' }
        }
      }

      response '201', 'Oluşturuldu' do
        let(:payload) do
          {
            profile: {
              user_id: member.id,
              first_name: 'Ada',
              last_name: 'Lovelace',
              bio: 'Pioneer of computing'
            }
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig('data', 'id')).to be_present
          expect(body.dig('data', 'first_name')).to eq('Ada')
        end
      end
    end
  end

  path '/api/v1/profiles/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Profil detay' do
      tags 'Profiles'
      produces 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true

      response '200', 'Başarılı' do
        let(:existing) { Profile.create!(account: account, user: member, first_name: 'Grace', last_name: 'Hopper') }
        let(:id) { existing.id }
        run_test!
      end
    end

    put 'Profil güncelle' do
      tags 'Profiles'
      consumes 'application/json'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          profile: { '$ref' => '#/components/schemas/ProfileInput' }
        }
      }

      response '200', 'Güncellendi' do
        let(:existing) { Profile.create!(account: account, user: member, first_name: 'Grace', last_name: 'Hopper') }
        let(:id) { existing.id }
        let(:payload) { { profile: { last_name: 'Updated' } } }

        run_test! do |response|
          body = JSON.parse(response.body)
          expect(body.dig('data', 'last_name')).to eq('Updated')
        end
      end
    end

    delete 'Profil sil' do
      tags 'Profiles'
      security [ bearerAuth: [] ]

      parameter name: :Authorization, in: :header, type: :string, required: true

      response '204', 'Silindi' do
        let(:existing) { Profile.create!(account: account, user: member, first_name: 'Alan', last_name: 'Turing') }
        let(:id) { existing.id }
        run_test!
      end
    end
  end
end
