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
        result = Profiles::UpdateAvatarService.call(profile: profile, file: params[:file])
        if result.success?
          render_resource(result.value, resource_blueprint)
        else
          render_errors(result.error, status: result.code || :unprocessable_entity)
        end
      end

      # DELETE /api/v1/profiles/:id/avatar
      def purge_avatar
        profile = policy_scope(Profile).find(params[:id])
        authorize(profile)
        result = Profiles::UpdateAvatarService.call(profile: profile, purge: true)
        if result.success?
          head :no_content
        else
          render_errors(result.error, status: result.code || :unprocessable_entity)
        end
      end

      # POST /api/v1/profiles/:id/avatar/attach
      # Params: signed_id (from direct upload)
      def attach_avatar
        profile = policy_scope(Profile).find(params[:id])
        authorize(profile)
        result = Profiles::UpdateAvatarService.call(profile: profile, signed_id: params[:signed_id].to_s)
        if result.success?
          render_resource(result.value, resource_blueprint)
        else
          render_errors(result.error, status: result.code || :unprocessable_entity)
        end
      end
    end
  end
end
