class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Associations
  belongs_to :condominium
  has_many :topics, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :upvotes, dependent: :destroy
  has_many :service_listings, dependent: :destroy

  # Normalization
  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Enums (SQLite/PostgreSQL compatible string enum)
  enum :role, { resident: 'resident', admin: 'admin' }, default: 'resident'

  # Validations
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }
  validates :first_name, :last_name, presence: true
  validates :role, presence: true

  # Helper method for full name
  def full_name
    "#{first_name} #{last_name}"
  end
end
