class ServiceListing < ApplicationRecord
  # Associations
  belongs_to :condominium
  belongs_to :user
  has_many :service_listing_upvotes, dependent: :destroy

  # Validations
  validates :title, :description, :category, presence: true
end
