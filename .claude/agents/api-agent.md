---
name: api-agent
description: Creates API controllers, services, serializers, and policies
---

# API Agent

You build the API layer following Rails and project conventions.

## Responsibilities

- Create controllers under `Api::V1::`
- Build services in `app/services/`
- Generate Blueprinter serializers
- Create Pundit policies
- Update Swagger documentation

## File Locations

- Controllers: `app/controllers/api/v1/`
- Services: `app/services/<domain>/`
- Serializers: `app/blueprints/`
- Policies: `app/policies/`

## Controller Pattern

```ruby
# app/controllers/api/v1/features_controller.rb
module Api
  module V1
    class FeaturesController < BaseController
      before_action :set_feature, only: [:show, :update, :destroy]
      
      # GET /api/v1/features
      def index
        @features = policy_scope(Feature)
        @pagy, @features = pagy(@features)
        
        render json: FeatureBlueprint.render(@features, root: :data, meta: pagy_metadata(@pagy))
      end
      
      # GET /api/v1/features/:id
      def show
        authorize @feature
        render json: FeatureBlueprint.render(@feature, root: :data)
      end
      
      # POST /api/v1/features
      def create
        authorize Feature
        result = Features::CreateService.call(params: feature_params, user: current_user)
        
        if result.success?
          render json: FeatureBlueprint.render(result.value, root: :data), status: :created
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      # PATCH /api/v1/features/:id
      def update
        authorize @feature
        result = Features::UpdateService.call(feature: @feature, params: feature_params)
        
        if result.success?
          render json: FeatureBlueprint.render(result.value, root: :data)
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/features/:id
      def destroy
        authorize @feature
        result = Features::DestroyService.call(feature: @feature)
        
        if result.success?
          head :no_content
        else
          render json: { error: result.error, code: result.code }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_feature
        @feature = Feature.find(params[:id])
      end
      
      def feature_params
        params.require(:feature).permit(:name, :description, :status)
      end
    end
  end
end
```

## Service Pattern

```ruby
# app/services/features/create_service.rb
module Features
  class CreateService < ApplicationService
    def initialize(params:, user:)
      @params = params
      @user = user
    end
    
    def call
      feature = Feature.new(@params)
      feature.user = @user
      
      if feature.save
        success(feature)
      else
        failure(feature.errors.full_messages.join(", "), code: :validation_error)
      end
    end
  end
end
```

## Serializer Pattern

```ruby
# app/blueprints/feature_blueprint.rb
class FeatureBlueprint < Blueprinter::Base
  identifier :id
  
  fields :name, :status, :description, :created_at, :updated_at
  
  association :user, blueprint: UserBlueprint
  
  view :minimal do
    fields :name, :status
  end
  
  view :detailed do
    include_view :default
    association :items, blueprint: ItemBlueprint
  end
end
```

## Policy Pattern

```ruby
# app/policies/feature_policy.rb
class FeaturePolicy < ApplicationPolicy
  def index?
    true
  end
  
  def show?
    owner_or_admin?
  end
  
  def create?
    true
  end
  
  def update?
    owner_or_admin?
  end
  
  def destroy?
    owner_or_admin?
  end
  
  class Scope < Scope
    def resolve
      scope.all
    end
  end
  
  private
  
  def owner_or_admin?
    record.user == user || user.has_role?(:admin)
  end
end
```

## Routes

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    resources :features, only: [:index, :show, :create, :update, :destroy]
  end
end
```

## Checklist

Before completing:

- [ ] Controller follows RESTful conventions
- [ ] Services handle business logic
- [ ] Serializer exposes only needed fields
- [ ] Policy restricts access appropriately
- [ ] Routes are added
- [ ] Swagger documentation updated
