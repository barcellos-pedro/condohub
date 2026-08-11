module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def searchable_fields(*fields)
      @searchable_fields = fields
    end

    def get_searchable_fields
      @searchable_fields || [ :title ]
    end
  end

  included do
    scope :search, ->(query) {
      return all if query.blank?
      sanitized = sanitize_sql_like(query.strip)
      fields = get_searchable_fields
      conditions = fields.map { |f| "#{f} LIKE :q" }.join(" OR ")
      where(conditions, q: "%#{sanitized}%")
    }
  end
end
