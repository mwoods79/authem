class Authem::Session < ActiveRecord::Base

  self.table_name = "authem_sessions"

  belongs_to :authemable, polymorphic: true

  before_validation :set_unique_token

  scope :active, -> {
    t = arel_table; where(t["updated_at"].gteq(2.weeks.ago)).where(revoked_at: nil)
  }

  def self.authenticate(session_token)
    self.active.find_by(token: session_token)
  end

  def revoke!
    self.revoked_at = Time.now
    save!
  end

  private

  def set_unique_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
