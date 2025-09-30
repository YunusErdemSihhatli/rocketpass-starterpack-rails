module Api
  module V1
    class ProfilesController < ResourceController
      self.resource_model = Profile
      self.resource_blueprint = ProfileBlueprint

      private

      def resource_params
        params.require(:profile).permit(:user_id, :first_name, :last_name, :bio).merge(account_id: current_user.account_id)
      end

      public

      # POST /api/v1/profiles/:id/avatar
      def avatar
        profile = policy_scope(Profile).find(params[:id])
        authorize(profile)
        unless params[:file].present?
          return render_errors('file is required')
        end
        profile.avatar.attach(params[:file])
        if profile.save
          render_resource(profile, resource_blueprint)
        else
          render_errors(profile.errors.full_messages)
        end
      end

      # DELETE /api/v1/profiles/:id/avatar
      def purge_avatar
        profile = policy_scope(Profile).find(params[:id])
        authorize(profile)
        if profile.avatar.attached?
          profile.avatar.purge
        end
        head :no_content
      end

      # POST /api/v1/profiles/:id/avatar/attach
      # Params: signed_id (from direct upload)
      def attach_avatar
        profile = policy_scope(Profile).find(params[:id])
        authorize(profile)
        signed_id = params[:signed_id].to_s
        return render_errors('signed_id is required') if signed_id.blank?
        profile.avatar.attach(signed_id)
        if profile.save
          render_resource(profile, resource_blueprint)
        else
          render_errors(profile.errors.full_messages)
        end
      end
    end
  end
end
