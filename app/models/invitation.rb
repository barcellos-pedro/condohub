class Invitation < ApplicationRecord
  has_secure_token :token

  # Associations
  belongs_to :condominium
  belongs_to :invited_by, class_name: "User", foreign_key: "user_id"

  # Normalization
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Validations
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :email_not_already_registered, on: :create

  before_validation :set_default_expiration, on: :create

  scope :pending, -> { where(accepted_at: nil).where("expires_at > ?", Time.current) }
  scope :expired, -> { where(accepted_at: nil).where("expires_at <= ?", Time.current) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def expired?
    expires_at <= Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def pending?
    !expired? && !accepted?
  end

  def accept!
    update!(accepted_at: Time.current)
  end

  private

  def set_default_expiration
    self.expires_at ||= 7.days.from_now
  end

  def email_not_already_registered
    if email_address.present? && User.exists?(email_address: email_address.strip.downcase)
      errors.add(:email_address, :already_registered)
    end
  end
end
