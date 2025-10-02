module Api
  module V1
    class ResourceController < BaseController
      include Pagy::Backend
      include Rendering

      class_attribute :resource_model, :resource_blueprint

      def index
        scope = apply_scope(resource_model)
        scope = policy_scope(scope)
        scope = apply_ransack(scope)
        scope = apply_search(scope)
        authorize(resource_model) # calls index? on policy class
        @pagy, records = pagy(scope)
        render_collection(records, resource_blueprint)
      end

      def show
        record = apply_scope(resource_model).find(params[:id])
        authorize(record)
        render_resource(record, resource_blueprint)
      end

      def create
        record = apply_scope(resource_model).new(resource_params)
        authorize(record)
        result = Resources::CreateService.call(record: record)
        if result.success?
          render_resource(result.value, resource_blueprint, status: :created)
        else
          render_errors(result.error)
        end
      end

      def update
        record = apply_scope(resource_model).find(params[:id])
        authorize(record)
        result = Resources::UpdateService.call(record: record, attributes: resource_params)
        if result.success?
          render_resource(result.value, resource_blueprint)
        else
          render_errors(result.error)
        end
      end

      def destroy
        record = apply_scope(resource_model).find(params[:id])
        authorize(record)
        result = Resources::DestroyService.call(record: record)
        if result.success?
          head :no_content
        else
          render_errors(result.error)
        end
      end

      private

      def apply_scope(scope)
        scope.all
      end

      def apply_ransack(scope)
        if params[:q].present?
          scope = scope.ransack(params[:q]).result(distinct: true)
        end
        scope
      end

      def apply_search(scope)
        if params[:search].present? && scope.respond_to?(:search_text)
          scope = scope.search_text(params[:search])
        end
        scope
      end

      # Subclass should override and strong-permit attributes
      def resource_params
        raise NotImplementedError, 'Implement resource_params in subclass'
      end
    end
  end
end
