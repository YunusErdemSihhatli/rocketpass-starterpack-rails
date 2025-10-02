module Profiles
  class UpdateAvatarService < ApplicationService
    def initialize(profile:, file: nil, signed_id: nil, purge: false)
      @profile = profile
      @file = file
      @signed_id = signed_id
      @purge = purge
    end

    def call
      if @purge
        purge_avatar
      else
        attach_avatar
      end
    end

    private

    def attach_avatar
      unless @file.present? || @signed_id.present?
        return failure(I18n.t('services.profiles.update_avatar.errors.missing_avatar'), code: :bad_request)
      end

      if @file.present?
        @profile.avatar.attach(@file)
      elsif @signed_id.present?
        @profile.avatar.attach(@signed_id)
      end

      if @profile.save
        success(@profile)
      else
        failure(@profile.errors.full_messages)
      end
    end

    def purge_avatar
      if @profile.avatar.attached?
        @profile.avatar.purge
      end
      success(nil)
    end
  end
end
