## Executive Summary

| Workstream                     | Features  | Priority  | Effort  | Status |
| ------------------------------ | --------- | --------- | ------- | ------ |
| **A. Content Governance**      | 1         | 🔴 High   | Low     | OK     |
| **B. User Identity**           | 2 + 4     | 🔴 High   | Low     | OK     |
| **C. Announcement Delivery**   | 3         | 🔴 High   | Low-Med |        |
| **D. Feed Discovery**          | 5 + 6 + 7 | 🟡 Medium | Low-Med |        |
| **E. Comment Engagement**      | 8         | 🟡 Medium | Medium  |        |
| **F. Admin Intelligence**      | 9         | 🟢 Low    | Medium  |        |
| **G. Notification Center**     | 10        | 🟢 Low    | High    |        |
| **H. Self-Service Onboarding** | 11        | 🟢 Low    | High    |        |

## Workstream A: Content Governance
**Feature 1 — Edit/Delete Topics & ServiceListings**

### Scope
- Authors can edit/delete their own topics and service listings
- Admins can edit/delete any content in their condominium
- In-place editing via standard Rails forms (not inline)

### Files to Create
```
app/views/topics/edit.html.erb          # reuse _form partial
app/views/service_listings/edit.html.erb # reuse _form partial
test/controllers/topics_controller_test.rb      # add edit/update/destroy cases
test/controllers/service_listings_controller_test.rb # add edit/update/destroy cases
```

### Files to Modify
**`app/controllers/topics_controller.rb`**
```ruby
before_action :set_topic, only: [:show, :edit, :update, :destroy]
before_action :require_owner, only: [:edit, :update, :destroy]

def edit
end

def update
  if @topic.update(topic_params)
    redirect_to @topic, notice: t(".updated")
  else
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  @topic.destroy
  redirect_to dashboard_path, notice: t(".destroyed")
end

private

def set_topic
  @topic = current_condominium.topics.find(params[:id])
end

def require_owner
  unless @topic.user_id == current_user.id || current_user.admin?
    redirect_to dashboard_path, alert: t("not_authorized")
  end
end
```

**`app/controllers/service_listings_controller.rb`** — identical pattern.

**`config/routes.rb`** — expand existing resources:
```ruby
resources :topics, only: [:show, :create, :edit, :update, :destroy]
resources :service_listings, only: [:show, :create, :edit, :update, :destroy]
```

**Views** — Add edit/delete buttons visible only to owner/admin:
```erb
<% if topic.user == current_user || current_user.admin? %>
  <%= link_to t("edit"), edit_topic_path(topic) %>
  <%= button_to t("delete"), topic_path(topic), method: :delete, data: { turbo_confirm: t("confirm") } %>
<% end %>
```
Add to: `app/views/topics/show.html.erb`, topic cards in dashboard, service listing cards.

### Schema Changes
**None.**

### Interface Contract
- Exposes: No new public API
- Consumes: `current_user.admin?` must exist (it does per doc)

### Test Requirements
- Owner can edit/update/destroy their own topic
- Non-owner gets redirected with alert
- Admin can edit/destroy any topic in their condo
- Cross-condo topic access returns 404 (ActiveRecord::RecordNotFound)

---

## Workstream B: User Identity
**Features 2 + 4 — Profile Editing & Public Resident Profile**

### Scope
- `/profile/edit` — logged-in user edits own name, email, password (requires current password)
- `/residents/:id` — public profile showing user's contributions (topics, comments, services, vouches)
- Header name becomes clickable link to profile
- Author names across site link to public profile

### Files to Create
```
app/controllers/profiles_controller.rb
app/controllers/residents_controller.rb
app/views/profiles/edit.html.erb
app/views/residents/show.html.erb
test/controllers/profiles_controller_test.rb
test/controllers/residents_controller_test.rb
```

### Files to Modify
**`app/models/user.rb`** — add at bottom of class:
```ruby
validates :email_address, presence: true, 
          uniqueness: { case_sensitive: false }, 
          format: { with: URI::MailTo::EMAIL_REGEXP }

def full_name
  "#{first_name} #{last_name}".strip
end

def active_contributions
  {
    topics: topics.count,
    comments: comments.count,
    services: service_listings.count,
    vouches: upvotes.count
  }
end
```

**`app/controllers/profiles_controller.rb`**
```ruby
class ProfilesController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if password_change_requested? && !@user.authenticate(params[:user][:current_password])
      flash.now[:alert] = t(".wrong_password")
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(user_params)
      redirect_to edit_profile_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
  end

  def password_change_requested?
    params[:user][:password].present?
  end
end
```

**`app/controllers/residents_controller.rb`**
```ruby
class ResidentsController < ApplicationController
  before_action :require_login

  def show
    @resident = current_condominium.users.find(params[:id])
    @recent_topics = @resident.topics.order(created_at: :desc).limit(10)
    @recent_comments = @resident.comments.order(created_at: :desc).limit(10)
    @services = @resident.service_listings.order(created_at: :desc).limit(10)
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: t("not_found")
  end
end
```

**`config/routes.rb`**
```ruby
resource :profile, only: [:edit, :update]
resources :residents, only: [:show]
```

**`app/views/layouts/_header.html.erb`** (or nav partial)
Change user display from static text to:
```erb
<%= link_to current_user.full_name, edit_profile_path, class: "profile-link" %>
```

**Author links** — In `app/views/topics/show.html.erb` and dashboard topic cards:
```erb
<%= link_to topic.user.full_name, resident_path(topic.user), class: "author-link" %>
```

### Schema Changes
**None.** Uses existing `first_name`, `last_name`, `email_address`.

### Interface Contract
- Exposes: `resident_path(user)`, `edit_profile_path`, `profile_path`
- Consumes: `User#full_name`, `User#topics`, `User#comments`, `User#service_listings`, `User#upvotes`

### Test Requirements
- Profile update with valid data succeeds
- Profile update with duplicate email fails
- Password change requires current password
- Public profile shows correct resident data
- Accessing resident from different condominium returns 404

---

## Workstream C: Announcement Delivery
**Feature 3 — Email Notifications for Official Announcements**

### Scope
- When an admin creates a `Topic` with `topic_type: "announcement"`, every resident in that condominium receives an email
- Delivery is async via Solid Queue (`deliver_later`)
- Email contains announcement title, content, author name, and link back to app

### Files to Create
```
app/mailers/announcement_mailer.rb
app/views/announcement_mailer/notify.html.erb
app/views/announcement_mailer/notify.text.erb
test/mailers/announcement_mailer_test.rb
test/models/topic_test.rb # callback test
```

### Files to Modify
**`app/models/topic.rb`** — add at bottom of class:
```ruby
after_create_commit :notify_residents, if: :announcement?

def announcement?
  topic_type == "announcement"
end

private

def notify_residents
  return unless condominium

  condominium.users.find_each do |user|
    AnnouncementMailer.notify(user, self).deliver_later
  end
end
```

**`app/mailers/announcement_mailer.rb`**
```ruby
class AnnouncementMailer < ApplicationMailer
  def notify(user, announcement)
    @user = user
    @announcement = announcement
    @condominium = announcement.condominium

    mail(
      to: user.email_address,
      subject: t(".subject", condominium: @condominium.name, title: announcement.title)
    )
  end
end
```

**`app/views/announcement_mailer/notify.html.erb`**
```erb
<h1><%= t(".headline", condominium: @condominium.name) %></h1>
<h2><%= @announcement.title %></h2>
<p><%= @announcement.content %></p>
<p><%= t(".author", name: @announcement.user.full_name) %></p>
<%= link_to t(".view"), topic_url(@announcement) %>
```

**`config/locales/en.yml`** (and others):
```yaml
en:
  announcement_mailer:
    notify:
      subject: "[%{condominium}] New Announcement: %{title}"
      headline: "New announcement from %{condominium}"
      author: "Posted by %{name}"
      view: "View in CondoHub"
```

### Schema Changes
**None.**

### Interface Contract
- Exposes: Mailer delivery enqueued automatically on announcement creation
- Consumes: `Topic#condominium`, `Condominium#users`, `User#email_address`
- Requires: Solid Queue processor running (`bin/jobs` or configured worker)

### Test Requirements
- Creating a discussion does NOT enqueue emails
- Creating an announcement enqueues exactly N emails (where N = resident count)
- Mailer body contains announcement title and link
- Cross-condo leakage: email only sends to users in announcement's condominium

---

## Workstream D: Feed Discovery
**Features 5 + 6 + 7 — Search, Pagination, Predefined Categories**

### Scope
- Search topics and services by keyword (title + content) via `LIKE` query
- Pagination: 20 items per page, "Load more" via Turbo Frame
- Service categories: predefined select list with filter links

### Files to Create
```
app/views/shared/_pagination.html.erb      # or "load more" turbo frame
test/controllers/dashboard_controller_test.rb # search/pagination tests
```

### Files to Modify
**`app/models/topic.rb`** — add scopes:
```ruby
scope :search, ->(query) {
  return all if query.blank?
  sanitized = sanitize_sql_like(query.strip)
  where("title LIKE :q OR content LIKE :q", q: "%#{sanitized}%")
}
```

**`app/models/service_listing.rb`** — add scopes and constants:
```ruby
CATEGORIES = %w[
  Hidráulica Elétrica Limpeza Jardinagem 
  Pintura Chaveiro Mudança Vigilância Outros
].freeze

validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

scope :search, ->(query) {
  return all if query.blank?
  sanitized = sanitize_sql_like(query.strip)
  where("title LIKE :q OR description LIKE :q", q: "%#{sanitized}%")
}

scope :by_category, ->(category) {
  return all if category.blank?
  where(category: category)
}
```

**`app/controllers/dashboard_controller.rb`** — D owns the `index` action body:
```ruby
def index
  @tab = params[:tab] || "discussions"
  @query = params[:q].to_s.strip
  @category = params[:category]
  @page = (params[:page].to_i || 0)
  @per_page = 20

  # Topics (discussions + announcements)
  @topics = current_condominium.topics
  @topics = @topics.search(@query) if @query.present?
  @topics = @topics.order(created_at: :desc)
                     .limit(@per_page)
                     .offset(@page * @per_page)

  # Services
  @services = current_condominium.service_listings
  @services = @services.search(@query) if @query.present?
  @services = @services.by_category(@category) if @category.present?
  @services = @services.order(created_at: :desc)
                         .limit(@per_page)
                         .offset(@page * @per_page)

  @next_page = @page + 1
  @has_more_topics = current_condominium.topics.search(@query).count > (@page + 1) * @per_page
  @has_more_services = current_condominium.service_listings.search(@query).by_category(@category).count > (@page + 1) * @per_page
end
```

**`app/views/dashboard/index.html.erb`**
Add at top of each tab:
```erb
<%= form_with url: dashboard_path, method: :get, local: true do |f| %>
  <%= hidden_field_tag :tab, @tab %>
  <%= text_field_tag :q, @query, placeholder: t("search.placeholder") %>
  <%= submit_tag t("search.button") %>
<% end %>

<% if @tab == "services" %>
  <div class="category-filters">
    <%= link_to t("all"), dashboard_path(tab: "services", q: @query) %>
    <% ServiceListing::CATEGORIES.each do |cat| %>
      <%= link_to cat, dashboard_path(tab: "services", category: cat, q: @query), 
          class: ("active" if @category == cat) %>
    <% end %>
  </div>
<% end %>
```

Wrap lists in Turbo Frame for pagination:
```erb
<%= turbo_frame_tag "topics_list" do %>
  <% @topics.each do |topic| %>
    <%= render topic %>
  <% end %>

  <% if @has_more_topics %>
    <%= link_to t("load_more"), dashboard_path(tab: "discussions", page: @next_page, q: @query), 
        data: { turbo_frame: "topics_list" } %>
  <% end %>
<% end %>
```

**Service form** (wherever services are created):
Change `text_field :category` to:
```erb
<%= form.select :category, ServiceListing::CATEGORIES, include_blank: true %>
```

### Schema Changes
**None.** (String `category` column already exists.)

### Interface Contract
- Exposes: `Topic.search(query)`, `ServiceListing.search(query)`, `ServiceListing::CATEGORIES`, `ServiceListing.by_category(cat)`
- Consumes: Existing dashboard tab params (`tab=discussions|services|announcements`)

### Test Requirements
- Search finds topics by title/content
- Search finds services by title/description
- Pagination returns exactly 20 items
- Category filter shows only matching services
- Empty search returns all results
- Cross-condo content never appears in search results

---

## Workstream E: Comment Engagement
**Feature 8 — Upvotes on Comments**

### Scope
- Comments can receive upvotes using the existing polymorphic `Upvote` model
- One upvote per user per comment (unique index or application-level check)
- Real-time counter update via Turbo Stream

### Files to Create
```
db/migrate/xxx_add_upvotes_count_to_comments.rb
test/controllers/upvotes_controller_test.rb # comment upvote cases
```

### Files to Modify
**Migration:**
```ruby
class AddUpvotesCountToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :upvotes_count, :integer, default: 0, null: false
  end
end
```

**`app/models/comment.rb`** — add associations:
```ruby
has_many :upvotes, as: :upvotable, dependent: :destroy
counter_cache :upvotes_count  # if using counter_cache properly, or just let Upvote model handle it
```

**`app/controllers/upvotes_controller.rb`** — refactor to support comments:
```ruby
class UpvotesController < ApplicationController
  before_action :require_login
  before_action :set_upvotable

  def create
    @upvote = @upvotable.upvotes.build(user: current_user)

    if @upvote.save
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path }
        format.turbo_stream
      end
    else
      redirect_back fallback_location: root_path, alert: t(".already_voted")
    end
  end

  private

  def set_upvotable
    @upvotable = if params[:topic_id]
      current_condominium.topics.find(params[:topic_id])
    elsif params[:service_listing_id]
      current_condominium.service_listings.find(params[:service_listing_id])
    elsif params[:comment_id]
      Comment.joins(:topic)
             .where(topics: { condominium_id: current_condominium.id })
             .find(params[:comment_id])
    end
  end
end
```

**`config/routes.rb`**
```ruby
resources :comments do
  resource :upvote, only: [:create]
end
```

**`app/views/comments/_comment.html.erb`** — add upvote button:
```erb
<div class="comment" id="<%= dom_id(comment) %>">
  <p><%= comment.content %></p>

  <%= button_to upvote_comment_path(comment), method: :post, class: "upvote-btn" do %>
    ▲ <%= comment.upvotes_count %>
  <% end %>
</div>
```

**`app/views/upvotes/create.turbo_stream.erb`** (if not exists, or modify):
```erb
<%= turbo_stream.replace dom_id(@upvotable) do %>
  <%= render @upvotable %>
<% end %>
```

### Schema Changes
- `add_column :comments, :upvotes_count, :integer, default: 0, null: false`

### Interface Contract
- Exposes: `comment.upvotes_count`, `POST /comments/:id/upvote`
- Consumes: Existing `Upvote` model polymorphism

### Test Requirements
- User can upvote a comment once
- Duplicate upvote is rejected (returns error or silently ignores)
- Upvote increments counter cache
- Cross-condo comment upvote is blocked (404)
- Turbo Stream response updates the DOM

---

## Workstream F: Admin Intelligence
**Feature 9 — Condominium Metrics Dashboard**

### Scope
- Admin-only view at `/condominium` showing:
  - Total residents count
  - "Active" residents (posted topic/comment in last 30 days)
  - Topics created this month
  - Top 5 most-vouched services
  - 5 most recent announcements
- Link in sidebar visible only to admins

### Files to Create
```
app/views/condominiums/show.html.erb
test/controllers/condominiums_controller_test.rb # metrics access tests
```

### Files to Modify
**`app/controllers/condominiums_controller.rb`** — add `show`:
```ruby
before_action :require_admin, only: [:show]

def show
  @total_residents = current_condominium.users.count

  @active_residents = current_condominium.users
    .left_joins(:topics, :comments)
    .where("topics.created_at > ? OR comments.created_at > ?", 30.days.ago, 30.days.ago)
    .distinct
    .count

  @topics_this_month = current_condominium.topics
    .where(created_at: Time.current.beginning_of_month..)
    .count

  @top_services = current_condominium.service_listings
    .left_joins(:upvotes)
    .group("service_listings.id")
    .order("COUNT(upvotes.id) DESC")
    .limit(5)

  @recent_announcements = current_condominium.topics
    .where(topic_type: "announcement")
    .order(created_at: :desc)
    .limit(5)
end

private

def require_admin
  unless current_user.admin?
    redirect_to dashboard_path, alert: t("not_authorized")
  end
end
```

**`config/routes.rb`**
```ruby
resource :condominium, only: [:show, :edit, :update] # add :show to existing
```

**Sidebar / navigation** — add for admins:
```erb
<% if current_user.admin? %>
  <%= link_to "📊 #{t('metrics.title')}", condominium_path %>
<% end %>
```

### Schema Changes
**None.**

### Interface Contract
- Exposes: `condominium_path` (show action)
- Consumes: `current_condominium`, `current_user.admin?`

### Test Requirements
- Admin can access metrics page
- Non-admin is redirected
- Metrics reflect only current condominium data
- Top services ordered by upvote count

---

## Workstream G: Notification Center
**Feature 10 — In-App Unread Badges (Simplified MVP)**

### Scope
- Track when user last visited dashboard (`last_seen_at`)
- Show unread badge count on Announcements tab/link
- No real-time WebSocket (use page load calculation for MVP)
- Future: Action Cable + Turbo Streams

### Files to Create
```
db/migrate/xxx_add_last_seen_at_to_users.rb
test/controllers/dashboard_controller_test.rb # last_seen_at tests
```

### Files to Modify
**Migration:**
```ruby
class AddLastSeenAtToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :last_seen_at, :datetime
  end
end
```

**`app/controllers/dashboard_controller.rb`** — G adds before_action (compatible with D's index body):
```ruby
class DashboardController < ApplicationController
  before_action :update_last_seen_at, only: :index

  # D owns the index action body below
  def index
    # ... Workstream D logic ...
  end

  private

  def update_last_seen_at
    current_user.touch(:last_seen_at) if logged_in?
  end
end
```

**`app/views/layouts/_header.html.erb` or sidebar** — add badge:
```erb
<% if logged_in? %>
  <% unread = current_condominium.topics
        .where(topic_type: "announcement")
        .where("created_at > ?", current_user.last_seen_at || 1.year.ago)
        .count %>

  <%= link_to announcements_path do %>
    📢 Avisos
    <% if unread > 0 %>
      <span class="badge"><%= unread %></span>
    <% end %>
  <% end %>
<% end %>
```

### Schema Changes
- `add_column :users, :last_seen_at, :datetime`

### Interface Contract
- Exposes: `current_user.last_seen_at`
- Consumes: `Topic` announcement scope, `current_condominium.topics`
- Note: Does NOT conflict with Workstream D. D owns `index` query logic; G adds a `before_action`.

### Test Requirements
- `last_seen_at` updates on dashboard visit
- Badge shows correct count of unread announcements
- Badge hidden when count is zero
- Only announcements created after user's last visit are counted

---

## Workstream H: Self-Service Onboarding
**Feature 11 — Public Registration via Invitation**

### Scope
- Admins generate invitation links (token-based) for new residents
- Invitation sent via email contains unique URL
- Resident clicks URL, fills name + password, joins correct condominium automatically
- No open registration — invitation-only for security

### Files to Create
```
app/models/invitation.rb
app/controllers/invitations_controller.rb
app/controllers/registrations_controller.rb
app/mailers/invitation_mailer.rb
app/views/invitations/new.html.erb
app/views/invitations/show.html.erb
app/views/registrations/new.html.erb
app/views/invitation_mailer/invite.html.erb
db/migrate/xxx_create_invitations.rb
test/controllers/invitations_controller_test.rb
test/controllers/registrations_controller_test.rb
```

### Files to Modify
**Migration:**
```ruby
class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations do |t|
      t.references :condominium, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :accepted_at
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :invitations, :token, unique: true
  end
end
```

**`app/models/invitation.rb`**
```ruby
class Invitation < ApplicationRecord
  belongs_to :condominium
  belongs_to :invited_by, class_name: "User"

  has_secure_token :token

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, uniqueness: true

  def accepted?
    accepted_at.present?
  end

  def expired?
    expires_at < Time.current
  end

  def accept!
    update!(accepted_at: Time.current)
  end
end
```

**`app/models/condominium.rb`**
```ruby
has_many :invitations, dependent: :destroy
```

**`app/models/user.rb`**
```ruby
has_many :sent_invitations, class_name: "Invitation", foreign_key: "invited_by_id", dependent: :nullify
```

**`app/controllers/invitations_controller.rb`**
```ruby
class InvitationsController < ApplicationController
  before_action :require_login
  before_action :require_admin

  def new
    @invitation = current_condominium.invitations.build
  end

  def create
    @invitation = current_condominium.invitations.build(invitation_params)
    @invitation.invited_by = current_user
    @invitation.expires_at = 7.days.from_now

    if @invitation.save
      InvitationMailer.invite(@invitation).deliver_later
      redirect_to condominium_path, notice: t(".sent")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @invitation = Invitation.find_by!(token: params[:id])

    if @invitation.accepted? || @invitation.expired?
      redirect_to root_path, alert: t(".invalid")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".invalid")
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email)
  end

  def require_admin
    redirect_to dashboard_path unless current_user.admin?
  end
end
```

**`app/controllers/registrations_controller.rb`**
```ruby
class RegistrationsController < ApplicationController
  def new
    @invitation = Invitation.find_by!(token: params[:invitation_token])
    redirect_to root_path, alert: t(".invalid") if @invitation.accepted? || @invitation.expired?
    @user = User.new(email_address: @invitation.email)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".invalid")
  end

  def create
    @invitation = Invitation.find_by!(token: params[:invitation_token])

    if @invitation.accepted? || @invitation.expired?
      redirect_to root_path, alert: t(".invalid")
      return
    end

    @user = @invitation.condominium.users.build(user_params)

    if @user.save
      @invitation.accept!
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: t(".welcome")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
  end
end
```

**`config/routes.rb`**
```ruby
resources :invitations, only: [:new, :create, :show]
get "/register/:invitation_token", to: "registrations#new", as: :new_registration
post "/register/:invitation_token", to: "registrations#create", as: :registration
```

**`app/mailers/invitation_mailer.rb`**
```ruby
class InvitationMailer < ApplicationMailer
  def invite(invitation)
    @invitation = invitation
    @condominium = invitation.condominium

    mail(to: @invitation.email, subject: t(".subject", condominium: @condominium.name))
  end
end
```

**Admin sidebar** — add link:
```erb
<%= link_to t("invitations.new"), new_invitation_path %>
```

### Schema Changes
- `create_table :invitations`
- `add_column :users, :invited_by_id` (optional, via association)

### Interface Contract
- Exposes: `POST /invitations`, `GET /invitations/:token`, `GET|POST /register/:token`
- Consumes: `Condominium#users`, `User` creation with auth
- Security: Invitation token is the sole authorization mechanism; no open registration

### Test Requirements
- Admin can create invitation
- Invitation email enqueued with correct token URL
- Expired/accepted invitation rejects registration
- Registration creates user in correct condominium
- Duplicate email within condominium rejected
- Registration auto-logs in user
