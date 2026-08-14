class ServiceListing < ApplicationRecord
  include Searchable

  CATEGORIES = %w[
    plumbing
    electrical
    cleaning
    gardening
    painting
    locksmith
    moving
    security
    other
  ].freeze

  # Associations
  belongs_to :condominium
  belongs_to :user
  has_many :upvotes, as: :upvotable, dependent: :destroy

  # Validations
  validates :title, :description, presence: true
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  # Scopes
  searchable_fields :title, :description

  def editable_by?(user)
    return false if user.nil?
    self.user_id == user.id || user.admin?
  end

  scope :by_category, ->(category) {
    return all if category.blank?
    where(category: category)
  }
end
