class Upvote < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :topic, counter_cache: true

  # Validations
  validates :user_id, uniqueness: { scope: :topic_id, message: "has already upvoted this topic" }
end
