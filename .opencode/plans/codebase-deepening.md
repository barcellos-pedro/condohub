# CondoHub — Codebase Deepening Plan

Apply deep-module design across the whole project: small interfaces, hidden complexity, testable at the seam.

---

## Phase 1: Enrich Models + Authorization

**Goal**: Move authorization rules from controllers into models. Each model owns its own rules behind `editable_by?(user)`.

### 1.1 Topic#editable_by?

**File**: `app/models/topic.rb`

Add before `private`:

```ruby
def editable_by?(user)
  return false if user.nil?
  return user.admin? if announcement?
  self.user_id == user.id
end
```

**Rules hidden**: announcement → admin only; discussion → owner only.

### 1.2 ServiceListing#editable_by?

**File**: `app/models/service_listing.rb`

Add before `scope :by_category`:

```ruby
def editable_by?(user)
  return false if user.nil?
  self.user_id == user.id || user.admin?
end
```

**Rules hidden**: owner OR admin.

### 1.3 Comment#editable_by?

**File**: `app/models/comment.rb`

Add before final `end`:

```ruby
def editable_by?(user)
  return false if user.nil?
  self.user_id == user.id
end
```

**Rules hidden**: owner only.

### 1.4 Simplify controllers

**TopicsController** — replace `require_owner`:

```ruby
def require_owner
  unless @topic.editable_by?(current_user)
    redirect_to dashboard_path, alert: t("flash.topics.not_authorized")
  end
end
```

**ServiceListingsController** — replace `require_owner`:

```ruby
def require_owner
  unless @service_listing.editable_by?(current_user)
    redirect_to dashboard_path(tab: "services"), alert: t("flash.service_listings.not_authorized")
  end
end
```

**CommentsController** — replace `require_comment_owner`:

```ruby
def require_comment_owner
  redirect_to topic_path(@topic), alert: t("flash.comments.not_authorized") unless @comment.editable_by?(current_user)
end
```

### 1.5 Model tests

**File**: `test/models/topic_test.rb`

```ruby
require "test_helper"

class TopicTest < ActiveSupport::TestCase
  test "owner can edit their discussion" do
    assert topics(:three).editable_by?(users(:three))
  end

  test "non-owner cannot edit discussion" do
    assert_not topics(:three).editable_by?(users(:one))
  end

  test "admin can edit announcement" do
    assert topics(:four).editable_by?(users(:one))
  end

  test "non-admin cannot edit announcement even if they own it" do
    assert_not topics(:four).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not topics(:one).editable_by?(nil)
  end
end
```

**File**: `test/models/service_listing_test.rb`

```ruby
require "test_helper"

class ServiceListingTest < ActiveSupport::TestCase
  test "owner can edit" do
    assert service_listings(:one).editable_by?(users(:one))
  end

  test "admin can edit" do
    assert service_listings(:three).editable_by?(users(:one))
  end

  test "non-owner non-admin cannot edit" do
    assert_not service_listings(:one).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not service_listings(:one).editable_by?(nil)
  end
end
```

**File**: `test/models/comment_test.rb`

```ruby
require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "owner can edit" do
    assert comments(:one).editable_by?(users(:one))
  end

  test "non-owner cannot edit" do
    assert_not comments(:one).editable_by?(users(:three))
  end

  test "nil user cannot edit" do
    assert_not comments(:one).editable_by?(nil)
  end
end
```

---

## Phase 2: Upvote Toggle

**Goal**: Move toggle logic from controller into `Upvote.toggle`.

### 2.1 Upvote.toggle class method

**File**: `app/models/upvote.rb`

Add class method:

```ruby
def self.toggle(user:, upvotable:)
  existing = upvotable.upvotes.find_by(user: user)
  if existing
    existing.destroy
    :removed
  else
    upvotable.upvotes.create!(user: user)
    :added
  end
end
```

### 2.2 Simplify UpvotesController

**File**: `app/controllers/upvotes_controller.rb`

Replace `create` action:

```ruby
def create
  result = Upvote.toggle(user: current_user, upvotable: @upvotable)
  redirect_back fallback_location: fallback_path, notice: success_message(result)
end
```

Update `success_message` to accept the action symbol directly:

```ruby
def success_message(action)
  case @upvotable
  when Topic
    t("flash.upvotes.#{action}")
  when ServiceListing
    t("flash.service_listings.vouch_#{action}", title: @upvotable.title)
  when Comment
    t("flash.comments.upvote_#{action}")
  end
end
```

### 2.3 Model test

**File**: `test/models/upvote_test.rb` — add:

```ruby
test "toggle creates upvote when absent" do
  topic = topics(:one)
  assert_difference -> { Upvote.where(upvotable: topic).count }, 1 do
    result = Upvote.toggle(user: users(:two), upvotable: topic)
    assert_equal :added, result
  end
end

test "toggle removes upvote when present" do
  topic = topics(:one)
  Upvote.create!(user: users(:two), upvotable: topic)
  assert_difference -> { Upvote.where(upvotable: topic).count }, -1 do
    result = Upvote.toggle(user: users(:two), upvotable: topic)
    assert_equal :removed, result
  end
end
```

---

## Phase 3: Condominium Metrics

**Goal**: Move 4 metric queries from controller into `Condominium#metrics`.

### 3.1 Condominium#metrics

**File**: `app/models/condominium.rb`

Add method:

```ruby
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
```

### 3.2 Simplify CondominiumsController#show

**File**: `app/controllers/condominiums_controller.rb`

Replace `show` action:

```ruby
def show
  @metrics = current_condominium.metrics
end
```

Update view to use `@metrics[:total_residents]`, `@metrics[:active_residents]`, etc.

### 3.3 Model test

**File**: `test/models/condominium_test.rb` (new file):

```ruby
require "test_helper"

class CondominiumTest < ActiveSupport::TestCase
  test "metrics returns expected keys" do
    metrics = condominiums(:one).metrics
    assert_includes metrics.keys, :total_residents
    assert_includes metrics.keys, :active_residents
    assert_includes metrics.keys, :topics_this_month
    assert_includes metrics.keys, :top_services
    assert_includes metrics.keys, :recent_announcements
  end

  test "metrics are scoped to condominium" do
    metrics = condominiums(:one).metrics
    assert_equal 2, metrics[:total_residents]
  end
end
```

---

## Phase 4: Dashboard Query Builder

**Goal**: Extract scope-building, branching, and pagination from `DashboardController#index` into a deep module.

### 4.1 Dashboard module

**File**: `app/models/dashboard.rb` (new file)

```ruby
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
```

### 4.2 Simplify DashboardController#index

**File**: `app/controllers/dashboard_controller.rb`

Replace `index` action:

```ruby
def index
  @tab = params[:tab] || "discussions"
  @query = params[:q].to_s.strip
  @category = params[:category]
  @page = params[:page].to_i
  @per_page = 20

  result = Dashboard.query(
    condominium: current_condominium,
    tab: @tab,
    search: @query,
    category: @category,
    page: @page,
    per_page: @per_page
  )

  case @tab
  when "services"
    @services = result.items
    @has_more_services = result.has_more
    @new_service = result.new_record
  else
    @topics = result.items
    @has_more_topics = result.has_more
    @new_topic = result.new_record
  end

  @next_page = @page + 1
end
```

### 4.3 Model test

**File**: `test/models/dashboard_test.rb` (new file):

```ruby
require "test_helper"

class DashboardTest < ActiveSupport::TestCase
  test "query returns discussions by default" do
    result = Dashboard.query(condominium: condominiums(:one))
    assert_equal "discussions", result.tab
    assert result.items.any?
  end

  test "query returns announcements when tab is announcements" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "announcements")
    assert_equal "announcements", result.tab
  end

  test "query returns services when tab is services" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "services")
    assert_equal "services", result.tab
  end

  test "query filters by search term" do
    result = Dashboard.query(condominium: condominiums(:one), search: "Resident Discussion")
    assert result.items.any? { |t| t.title == "Resident Discussion" }
  end

  test "query filters services by category" do
    result = Dashboard.query(condominium: condominiums(:one), tab: "services", category: "cleaning")
    assert result.items.all? { |s| s.category == "cleaning" }
  end

  test "query respects pagination" do
    21.times do |i|
      Topic.create!(
        condominium: condominiums(:one),
        user: users(:one),
        title: "Pagination #{i}",
        content: "Content #{i}",
        topic_type: :discussion
      )
    end
    result = Dashboard.query(condominium: condominiums(:one), page: 0, per_page: 20)
    assert_equal 20, result.items.size
    assert result.has_more
  end

  test "query scopes to condominium" do
    result = Dashboard.query(condominium: condominiums(:one))
    assert result.items.all? { |t| t.condominium_id == condominiums(:one).id }
  end
end
```

---

## Phase 5: Verify

```bash
bin/rails test
bin/rubocop
bin/ci
```

---

## Summary of Deepening

| Before | After | Depth gain |
|---|---|---|
| 3 controllers with `require_owner` logic | 3 models with `editable_by?` | Rules live at the domain seam, tested once per model |
| UpvotesController with toggle + polymorphic resolution | `Upvote.toggle` class method | Toggle logic is one call, tested through model interface |
| CondominiumsController with 4 metric queries | `Condominium#metrics` | One method hides all query complexity |
| DashboardController with 3 branches + pagination | `Dashboard.query` module | One interface hides all branching/pagination |

**Deletion test**: delete any of these modules and the complexity reappears across N callers — they're earning their keep.
