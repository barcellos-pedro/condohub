class Condominium < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :service_listings, dependent: :destroy

  validates :name, presence: true
end
