class Upvote < ApplicationRecord
  belongs_to :user
  belongs_to :upvotable, polymorphic: true, counter_cache: :upvotes_count

  validates :user_id, uniqueness: { scope: [ :upvotable_type, :upvotable_id ], message: "has already upvoted this" }
end
