class Comment < ApplicationRecord
  # Associations
  belongs_to :topic, counter_cache: :comments_count
  belongs_to :user
  has_many :upvotes, as: :upvotable, dependent: :destroy

  # Validations
  validates :content, presence: true

  def editable_by?(user)
    return false if user.nil?
    self.user_id == user.id
  end
end
