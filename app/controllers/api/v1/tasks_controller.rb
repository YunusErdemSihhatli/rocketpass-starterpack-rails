module Api
  module V1
    class TasksController < ResourceController
      self.resource_model = Task
      self.resource_blueprint = TaskBlueprint

      def event
        task = policy_scope(Task).find(params[:id])
        authorize(task)
        event = params.require(:event).to_s
        if task.aasm.may_fire_event?(event.to_sym)
          task.aasm.fire!(event.to_sym)
          render_resource(task, resource_blueprint)
        else
          render_errors("Event '#{event}' is not allowed from state '#{task.state}'", status: :unprocessable_entity)
        end
      end

      private

      def resource_params
        params.require(:task).permit(:user_id, :title, :description).merge(account_id: current_user.account_id)
      end

      public

      # POST /api/v1/tasks/:id/attachments
      def attachments
        task = policy_scope(Task).find(params[:id])
        authorize(task)
        unless params[:files].present?
          return render_errors('files[] is required')
        end
        Array(params[:files]).each do |f|
          task.files.attach(f)
        end
        if task.save
          render_resource(task, resource_blueprint)
        else
          render_errors(task.errors.full_messages)
        end
      end

      # DELETE /api/v1/tasks/:id/attachments/:attachment_id
      def purge_attachment
        task = policy_scope(Task).find(params[:id])
        authorize(task)
        attachment = task.files.attachments.find_by(id: params[:attachment_id])
        return render_errors('attachment not found', status: :not_found) unless attachment
        attachment.purge
        head :no_content
      end

      # POST /api/v1/tasks/:id/attachments/attach
      # Params: signed_ids[] (array)
      def attach_signed
        task = policy_scope(Task).find(params[:id])
        authorize(task)
        signed_ids = Array(params[:signed_ids]).map(&:to_s).reject(&:blank?)
        return render_errors('signed_ids[] is required') if signed_ids.empty?
        signed_ids.each { |sid| task.files.attach(sid) }
        if task.save
          render_resource(task, resource_blueprint)
        else
          render_errors(task.errors.full_messages)
        end
      end
    end
  end
end
