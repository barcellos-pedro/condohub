class Comment < ApplicationRecord
  # Associations
  belongs_to :topic
  belongs_to :user

  # Validations
  validates :content, presence: true
end
