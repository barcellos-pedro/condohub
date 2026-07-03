class Topic < ApplicationRecord
  # Associations
  belongs_to :condominium
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :upvotes, dependent: :destroy

  # Enums
  enum :topic_type, { discussion: "discussion", announcement: "announcement" }, default: "discussion"

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :topic_type, presence: true

  # Custom business rule: Only admins can post announcements
  validate :announcements_only_by_admins, if: :announcement?

  # Scopes
  scope :discussions, -> { where(topic_type: :discussion) }
  scope :announcements, -> { where(topic_type: :announcement) }

  private

  def announcements_only_by_admins
    if user.nil? || !user.admin?
      errors.add(:topic_type, :admins_only)
    end
  end
end
