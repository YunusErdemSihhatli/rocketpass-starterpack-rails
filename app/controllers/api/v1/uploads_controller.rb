module Api
  module V1
    class UploadsController < BaseController
      skip_before_action :authenticate_user!, only: []

      # POST /api/v1/uploads/presign
      # Params: filename, content_type, byte_size, checksum (Base64 MD5)
      def presign
        require_params = %i[filename content_type byte_size checksum]
        missing = require_params.select { |k| params[k].blank? }
        return render_errors("Missing: #{missing.join(', ')}", status: :bad_request) if missing.any?

        blob = ActiveStorage::Blob.create_before_direct_upload!(
          filename: params[:filename],
          byte_size: params[:byte_size].to_i,
          checksum: params[:checksum],
          content_type: params[:content_type]
        )

        render json: {
          data: {
            signed_id: blob.signed_id,
            key: blob.key,
            filename: blob.filename.to_s,
            byte_size: blob.byte_size,
            content_type: blob.content_type,
            direct_upload: {
              url: blob.service_url_for_direct_upload,
              headers: blob.service_headers_for_direct_upload
            }
          }
        }, status: :ok
      end
    end
  end
end

