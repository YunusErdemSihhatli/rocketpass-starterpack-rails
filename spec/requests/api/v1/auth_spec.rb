require 'swagger_helper'

RSpec.describe 'Auth API', swagger_doc: 'v1/openapi.yaml', type: :request do
  path '/api/v1/auth' do
    post 'Kayıt ol (sign up)' do
      tags 'Auth'
      consumes 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            required: %i[email password password_confirmation],
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string },
              password_confirmation: { type: :string },
              account_name: { type: :string }
            }
          }
        }
      }

      response '200', 'Başarılı kayıt + tokenlar' do
        schema '$ref' => '#/components/schemas/AuthTokens'
        # run_test!  # İsteğe bağlı doğrulama
      end

      response '422', 'Doğrulama hatası' do
        # run_test!
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post 'Giriş yap (sign in)' do
      tags 'Auth'
      consumes 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            required: %i[email password],
            properties: {
              email: { type: :string, format: :email },
              password: { type: :string }
            }
          }
        }
      }

      response '200', 'Başarılı giriş + tokenlar' do
        schema '$ref' => '#/components/schemas/AuthTokens'
        # run_test!
      end

      response '401', 'Yetkisiz' do
        # run_test!
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete 'Çıkış yap (sign out)' do
      tags 'Auth'
      consumes 'application/json'

      parameter name: :payload, in: :body, required: false, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        }
      }

      response '204', 'Başarılı' do
        # run_test!
      end
    end
  end

  path '/api/v1/auth/refresh' do
    post 'Token yenile (refresh)' do
      tags 'Auth'
      consumes 'application/json'

      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %i[refresh_token],
        properties: {
          refresh_token: { type: :string }
        }
      }

      response '200', 'Yeni tokenlar' do
        schema '$ref' => '#/components/schemas/RefreshResponse'
        # run_test!
      end

      response '401', 'Geçersiz refresh token' do
        # run_test!
      end
    end
  end

  path '/api/v1/me' do
    get 'Me' do
      tags 'Users'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'Kullanıcı bilgileri' do
        schema type: :object, properties: {
          id: { type: :integer },
          email: { type: :string, format: :email },
          account_id: { type: :integer },
          roles: { type: :array, items: { type: :string } },
          permissions: { type: :array, items: { type: :string } }
        }
        # run_test!
      end

      response '401', 'Yetkisiz' do
        # run_test!
      end
    end
  end
end

