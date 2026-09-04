class Condominium < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :topics, dependent: :destroy
  has_many :service_listings, dependent: :destroy
  has_many :invitations, dependent: :destroy

  validates :name, presence: true
  validates :whatsapp_group_link, format: { with: /\Ahttps:\/\/chat\.whatsapp\.com\/.*\z/ }, allow_blank: true

  def metrics
    {
      total_residents: users.count,
      active_residents: active_residents_count,
      topics_this_month: topics_this_month_count,
      top_services: service_listings.order(upvotes_count: :desc).limit(5),
      recent_announcements: topics.announcements.order(created_at: :desc).limit(5)
    }
  end

  private

  def active_residents_count
    users.left_joins(:topics, :comments)
      .where("topics.created_at > ? OR comments.created_at > ?", 30.days.ago, 30.days.ago)
      .distinct.count
  end

  def topics_this_month_count
    topics.where(created_at: Time.current.beginning_of_month..).count
  end
end
