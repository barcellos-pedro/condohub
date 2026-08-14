module Dashboard
  Result = Struct.new(:items, :has_more, :new_record, :tab, keyword_init: true)

  def self.query(condominium:, tab: "discussions", search: "", category: nil, page: 0, per_page: 20)
    case tab
    when "announcements"
      query_announcements(condominium, search, page, per_page)
    when "services"
      query_services(condominium, search, category, page, per_page)
    else
      query_discussions(condominium, search, page, per_page)
    end
  end

  private

  def self.query_discussions(condominium, search, page, per_page)
    scope = condominium.topics.discussions.search(search)
    items = scope.includes(:user).order(upvotes_count: :desc, created_at: :desc)
                 .limit(per_page).offset(page * per_page)
    Result.new(
      items: items,
      has_more: scope.count > (page + 1) * per_page,
      new_record: condominium.topics.new(topic_type: :discussion),
      tab: "discussions"
    )
  end

  def self.query_announcements(condominium, search, page, per_page)
    scope = condominium.topics.announcements.search(search)
    items = scope.includes(:user).order(created_at: :desc)
                 .limit(per_page).offset(page * per_page)
    Result.new(
      items: items,
      has_more: scope.count > (page + 1) * per_page,
      new_record: condominium.topics.new(topic_type: :announcement),
      tab: "announcements"
    )
  end

  def self.query_services(condominium, search, category, page, per_page)
    scope = condominium.service_listings.search(search).by_category(category)
    items = scope.includes(:user, :upvotes)
                 .order(upvotes_count: :desc, created_at: :desc)
                 .limit(per_page).offset(page * per_page)
    Result.new(
      items: items,
      has_more: scope.count > (page + 1) * per_page,
      new_record: condominium.service_listings.new,
      tab: "services"
    )
  end
end
