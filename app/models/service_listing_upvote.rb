class ServiceListingUpvote < ApplicationRecord
  belongs_to :user
  belongs_to :service_listing, counter_cache: :upvotes_count

  validates :user_id, uniqueness: { scope: :service_listing_id, message: "has already vouched for this service listing" }
end
