class Upvote < ApplicationRecord
  belongs_to :user
  belongs_to :upvotable, polymorphic: true, counter_cache: :upvotes_count

  validates :user_id, uniqueness: { scope: [ :upvotable_type, :upvotable_id ], message: "has already upvoted this" }

  def self.toggle(user:, upvotable:)
    existing = upvotable.upvotes.find_by(user: user)
    if existing
      existing.destroy
      :removed
    else
      upvotable.upvotes.create!(user: user)
      :success
    end
  end
end
