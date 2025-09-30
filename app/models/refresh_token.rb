class RefreshToken < ApplicationRecord
  belongs_to :user

  scope :active, -> { where(revoked_at: nil).where('expires_at > ?', Time.current) }

  def self.generate_for!(user, user_agent: nil, ip: nil, ttl: 30.days)
    raw = SecureRandom.urlsafe_base64(64)
    digest = digest_for(raw)
    record = user.refresh_tokens.create!(
      token_digest: digest,
      user_agent: user_agent,
      ip: ip,
      expires_at: Time.current + ttl
    )
    [record, raw]
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present? || expires_at <= Time.current
  end

  def self.find_by_raw(token)
    where(token_digest: digest_for(token)).first
  end

  def self.digest_for(token)
    OpenSSL::Digest::SHA256.hexdigest(token)
  end
end

