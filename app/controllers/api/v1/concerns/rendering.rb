module Api
  module V1
    module Rendering
      def render_collection(collection, blueprint, status: :ok)
        if defined?(pagy)
          meta = pagy_metadata(@pagy)
        else
          meta = { count: collection.size }
        end
        render json: {
          data: blueprint.render_as_hash(collection),
          meta: meta
        }, status: status
      end

      def render_resource(resource, blueprint, status: :ok)
        render json: { data: blueprint.render_as_hash(resource) }, status: status
      end

      def render_errors(errors, status: :unprocessable_entity)
        render json: { errors: Array(errors) }, status: status
      end
    end
  end
end

