Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise auth
  devise_for :users

  # Admin dashboard (Administrate)
  namespace :admin do
    resources :users
    resources :accounts
    resources :roles
    resources :permissions
    resources :invitations, only: %i[new create]
    root to: "users#index"
  end

  # Root
  root "home#index"

  # API v1 with JWT auth
  namespace :api do
    namespace :v1 do
      scope defaults: { format: :json } do
        # Session endpoints will dispatch/revoke JWT via Devise-JWT
        devise_for :users,
                   path: '',
                   path_names: {
                     sign_in: 'auth/sign_in',
                     sign_out: 'auth/sign_out',
                     registration: 'auth'
                   },
                   controllers: {
                     sessions: 'api/v1/users/sessions',
                     registrations: 'api/v1/users/registrations'
                   }

        # Example protected resource
        get 'me', to: 'users#me'

        # Token refresh
        post 'auth/refresh', to: 'tokens#refresh'

        # Generic resources
        resources :profiles do
          member do
            post :avatar
            delete :purge_avatar
            post :attach_avatar
          end
        end
        resources :tasks do
          member do
            post :event
            post :attachments
          end
          post "attachments/attach", to: "attachments#attach_signed", on: :member
          delete 'attachments/:attachment_id', to: 'tasks#purge_attachment', on: :member
        end
        # Direct upload pre-sign endpoint
        post 'uploads/presign', to: 'uploads#presign'
      end
    end
  end

  # OAuth2 Provider (Doorkeeper)
  use_doorkeeper

  # Swagger / OpenAPI Docs (RSwag)
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Sidekiq Web (admin only)
  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.has_role?(:admin) } do
    mount Sidekiq::Web => '/admin/sidekiq'
  end
end
