class ServiceListing < ApplicationRecord
  # Associations
  belongs_to :condominium
  belongs_to :user

  # Validations
  validates :title, :description, :category, presence: true
end
