class Condominium < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :service_listings, dependent: :destroy

  validates :name, presence: true
  validates :whatsapp_group_link, format: { with: /\Ahttps:\/\/chat\.whatsapp\.com\/.*\z/ }, allow_blank: true
end
