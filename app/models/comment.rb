class Comment < ApplicationRecord
  # Associations
  belongs_to :topic
  belongs_to :user
  has_many :upvotes, as: :upvotable, dependent: :destroy

  # Validations
  validates :content, presence: true
end
