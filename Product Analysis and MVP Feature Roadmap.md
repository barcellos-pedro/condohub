## Current Project Summary

**CondoHub** is a multi-tenant condominium community platform built on Rails 8.1. The product serves residents and condominium administrators for three core use cases:

1. **Resident Discussions** — a forum with Reddit-style upvotes, restricted to the user's condominium

2. **Official Notices** — published only by admins, separate from the general conversation

3. **Local Service Catalog** — recommendations of service providers with a voucher system (upvote)

### Technologies & Current Maturity

| Dimension       | Status                                         |
| --------------- | ---------------------------------------------- |
| Auth            | ✅ Custom session-based, password with bcrypt   |
| Multi-tenancy   | ✅ Isolation by `condominium_id` in all queries |
| i18n            | ✅ 4 languages ​​(pt-BR, en, es, ko)            |
| Frontend        | ✅ Hotwire + Stimulus (no JS bundler)           |
| Background jobs | ✅ Solid Queue installed, no jobs configured    |
| Email           | ✅ Mailer active (password reset only)          |
| PWA             | ✅ Manifest and service worker stub exist       |
| Notifications   | ❌ Not implemented                              |
| User profile    | ❌ Only name and email                          |
| Content editing | ❌ Topics/Services without edit/delete          |
| Search          | ❌ Does not exist                               |
| Admin panel     | ⚠️ Only condominium editing                    |

### Identified Target Audience

- **Residents** (role: `resident`) — seek connection and information with the neighborhood
- **Administrators/Building Managers** (role: `admin`) — need efficient communication tools

---

## Feature Proposals — By Priority

> Ordered from **highest impact / lowest effort** to **lowest impact / highest effort**, considering the MVP stage.

---

### 🔴 HIGH PRIORITY

---

#### 1. Editing and Deleting Topics and Service Listings

- **Overview:** Topic and service listing authors cannot edit or delete their own posts. This is a fundamental gap — any content platform needs complete CRUD functionality.

- **Value for the User / Business:** Reduces frustration and errors. Without it, residents are left with permanently published incorrect content, which drives away new users.

- **Implementation Complexity:** **Low**

- **Existing Files/Entities Used:**

- `TopicsController` — add `edit`, `update`, `destroy`

- `ServiceListingsController` — add `edit`, `update`, `destroy`

- `Topic`, `ServiceListing` — already complete models

- `config/routes.rb` — expand `only:` in resources

- Views: `topics/edit.html.erb`, `service_listings/edit.html.erb`

- Locales: add flash keys and labels

- **High-Level Implementation Plan:**

1. Add `edit`, `update`, `destroy` actions to both controllers with `before_action :require_owner`

2. Extend routes: `resources :topics, only: [:show, [:create, :edit, :update, :destroy]

3. Create edit views (reusing form partials)

4. Add edit/delete buttons to dashboard cards and to `topics/show.html.erb` (visible only to the author or admin)

5. Ensure condominium isolation: always search via `current_condominium.topics.find(id)`

6. Controller tests: owner can edit, non-owner receives a 403 error

---

#### 2. User Profile — Editing Personal Data

- **Overview:** Users cannot update their name, email, or password after registration (except via the reset flow). There is no profile screen.

- **Value for the User / Business:** Retains users who make registration errors. Increases trust in the product by giving basic autonomy over their own account.

- **Implementation Complexity:** **Low**

- **Existing Files/Entities Used:**

- `User` model — attributes already exist: `first_name`, `last_name`, `email_address`

- `PasswordsController` — reference to the password flow

- `Authentication` concern — `current_user` available

- Locales: UI keys for the profile screen

- **High-Level Implementation Plan:**

1. Create `ProfilesController` with `edit` and `update` (singular resource `/profile`)

2. Add route `resource :profile, only: [:edit, :update]` to the locale scope

3. View with name, email, and optionally password fields (require current password for sensitive changes)

4. Link in the header (`current_user.full_name` clickable) pointing to `edit_profile_path`

5. Validation in the model: email must be unique even when updated

6. Controller Tests

---

#### 3. Email Notifications for New Announcements

- **Overview:** When an admin publishes an official announcement (`topic_type: announcement`), all residents of the building should be notified automatically via email.

- **Value for the User/Business:** This is the most critical use case for the product. A notice about elevator maintenance or a condominium meeting needs to reach everyone. This is the differentiating factor that justifies using CondoHub instead of WhatsApp.

- **Implementation Complexity:** **Low-Medium**

- **Existing Files/Entities Used:**

- `TopicsController#create` — `after_create` hook or callback in the controller

- `Topic` model — `after_create_commit` callback with `announcement?` check

- `ApplicationMailer` and `PasswordsMailer` — standard to follow

- `Solid Queue` — already installed, for `deliver_later`

- `Condominium#users` — list of recipients

- **High-Level Implementation Plan:**

1. Create `AnnouncementMailer` with `notify(user, announcement)` method

2. In the `Topic` model, add `after_create_commit :notify_residents, if: :announcement?`

3. The `notify_residents` method iterates 1. Create `condominium.users` and call `AnnouncementMailer.notify(...).deliver_later`

4. Create templates `announcement_mailer/notify.html.erb` and `.text.erb`

5. Add locale keys for the email subject and body

6. Test the mailer with `assert_emails`

---

#### 4. Resident Public Profile Page

- **Overview:** Clicking on an author's name should open a profile with their contributions: topics, comments, recommended services, and vouchers given. This creates social context and trust in the community.

- **Value for the User/Business:** Increases social cohesion. Residents who contribute more become a reference in the community, encouraging continuous engagement.

- **Implementation Complexity:** **Low**

- **Existing Files/Entities Used:**

- `User` model — `topics`, `comments`, `service_listings`, `upvotes` already associated

- New route: `resources :residents, only: [:show]` (or `users/:id`)

- Creation of `ResidentsController` or `UsersController`

- Isolation: filter only users from the same condominium

- **High-Level Implementation Plan:**

1. Create `ResidentsController#show` searching for users by `current_condominium.users.find(id)`

2. Add route `resources :residents, only: [:show]`

3. View with name, role badge, entry date, total topics/comments/services and recent listing

4. Transform the author's name into a link to `resident_path(topic.user)` in dashboard views and topics

5. Ensure that data from other condominiums does not leak

6. Tests: cross-condo access returns 404

---

### 🟡 MEDIUM PRIORITY

---

#### 5. Content Search on the Dashboard

- **Overview:** With the growth of topics and services, users will need to find older content. A simple keyword search field solves this.

- **Value for the User / Business:** Essential discovery functionality for content platforms. Directly related to retention — users who don't find what they're looking for don't return.

- **Implementation Complexity:** **Low-Medium**

- **Existing Files/Entities Used:**

- `DashboardController#index` — add parameter `q` and search scope

- `Topic` model — add scope `search(query)`

- `ServiceListing` model — same

- Dashboard View — add search field per tab

- **High-Level Implementation Plan:**

1. Add scope `search(query)` to the models using `LIKE` (SQLite supports `LIKE` case-insensitive to ASCII; sufficient for MVP)

2. In the `DashboardController`, check `params[:q]` and chain the scope: `current_condominium.topics.discussions.search(params[:q])`

3. Add a `<form>` GET at the top of each tab in the dashboard with `input[name=q]`

4. Preserve the search parameter when switching tabs (include in the tab link)

5. Highlight the searched term in the results (simple `highlight()` helper)

```ruby
# app/models/topic.rb
scope :search, ->(query) {
where("title LIKE :q OR content LIKE :q", q: "%#{sanitize_sql_like(query)}%")

}
```

---

#### 6. Pagination or Infinite Scroll of Topics and Services

- **Overview:** The dashboard loads all topics at once. As the condominium grows, this will become slow and visually cluttered.

- **Value for the User / Business:** Perceived performance improves. Larger condominiums become viable.

- **Implementation Complexity:** **Low-Medium**

- **Existing Files/Entities Used:**

- `DashboardController#index` — add `params[:page]` and `.limit().offset()`

- Dashboard view — "Load more" links or pagination

- Turbo Frames — to load more without a full reload

- **High-Level Implementation Plan:**

1. Add the `pagy` gem (lightweight, no JS dependencies) or manual implementation with `.limit(20).offset(...)`

2. In the controller, paginate the results: `@topics = ...search(q).page(params[:page]).per(20)`

3. In the view, add the `<turbo-frame id="topics-page-X">` block surrounding the cards

4. The "See more" link points to `dashboard_path(tab: @tab, page:` @pagy.next)` within a Turbo Frame

5. Simpler alternative: "See more" button with `data-turbo-frame="topics-list"`

---

#### 7. Predefined Categories for Service Listings

- **Overview:** Currently, `category` is a free text field. This generates inconsistencies ("Plumber", "plumber", "Hydraulics"). A predefined select improves the experience and allows filtering.

- **Value for the User/Business:** Improves service discovery. Filtering "all electricians" becomes possible and useful.

- **Implementation Complexity:** **Low**

- **Existing Files/Entities Used:**

- `ServiceListing` model — add `enum` or constant `CATEGORIES`

- Dashboard view — replace `text_field :category` with `select :category`

- `DashboardController` — add filter by `params[:category]`

- **High-Level Implementation Plan:**

1. Define category list in the model: `CATEGORIES = %w[Hydraulics Electrical Cleaning Gardening Painting Locksmith Moving Security Others]`

2. Add validation `validates :category, inclusion: { in: CATEGORIES }`

3. Migration may not be necessary (no enum in the DB)

4. Replace the text field with `form.select :category, ServiceListing::CATEGORIES`

5. Add category filters to the Services tab (links or select above the list)

6. Update locale keys for each category

---

#### 8. Reactions to Comments (Simple)

- **Overview:** Comments have no form of engagement beyond written responses. A simple reaction system (👍 / ❤️) would increase interaction without requiring a full response.

- **Value for User / Business:** Increases passive engagement. Residents who don't want to write can still participate, generating activity metrics for the admin.

- **Implementation Complexity:** **Medium**

- **Existing Files/Entities Used:**

- `Upvote` model — is **polymorphic** and supports any `upvotable_type`. Simply add `Comment` to the polymorphism

- `UpvotesController` — add route for comments

- `config/routes.rb` — `resources :comments do resource :upvote end`

- View `_comment.html.erb` — add upvote button

- **High-Level Implementation Plan:**

1. No migration needed — `upvotes` is already polymorphic with `upvotable_type`

2. Add `has_many :upvotes, as: :upvotable` to the `Comment` model

3. Add `counter_cache :upvotes_count` → migration to add column to `comments`

4. Add route: `resources :comments do resource :upvote, only: [:create] end`

5. Update `UpvotesController` to detect and fetch the Comment upvotable

6. Add `▲ N` button to the partial `_comment.html.erb`

---

### 🟢 LOW PRIORITY / FUTURE

---

#### 9. Administrative Panel — Condominium Metrics

- **Overview:** Administrators lack visibility into condominium activity: how many active residents, which topics are most engaging, when the last notice was. A simple metrics panel increases the perceived value for condominium managers.

- **Value for the User / Business:** Differentiating factor for converting condominium managers to the product. Provides insights for administrative decision-making.

- **Implementation Complexity:** **Medium**

- **Existing Files/Entities Used:**

- `Condominium` model — `users.count`, `topics.count`

- `Topic`, `ServiceListing`, `Comment`, `Upvote` — all with `created_at` for simple time series

- `CondominiumsController` — add `show` action with metrics

- New view: `condominiums/show.html.erb`

- **High-Level Implementation Plan:**

1. Add `show` to `CondominiumsController` (admin only)

2. Calculate metrics: active users (with sessions in the last 30 days), topics/month, top services

3. Use pure SQL or scopes in the models for aggregations

4. View with metric cards and tables (without charting library initially)

5. Add "📊" link "Metrics" in the sidebar for admins

---

#### 10. In-App Notifications (Unread Badge)

- **Overview:** When there are new notifications or comments on topics the user has participated in, display an unread count badge in the header or corresponding tab.

- **Value for User/Business:** Increases daily app returns. It's the central retention mechanism of any community feed.

- **Implementation Complexity:** **High**

- **Existing Files/Entities Used:**

- New table: `notification_reads` (user_id, notifiable_type, notifiable_id, read_at)

- Or a simpler approach: `user.last_seen_at` timestamp in the `User` model

- `Solid Cable` — already installed, for real-time Action Cable

- `Topic`, `Comment` — item count after `current_user.last_seen_at`

- **High-Level Implementation Plan:**

1. (Simple option) Add `last_seen_at` to `User`: migration + update via `before_action` in the `DashboardController`

2. Calculate badge: `current_condominium.topics.announcements.where("created_at > ?", current_user.last_seen_`at).count`

3. Display badge `(3)` in the "📢 Notices" tab of the sidebar

4. (Advanced option) Action Cable channel `NotificationsChannel` with Turbo Streams for real-time

---

#### 11. Public Registration / Onboarding of New Residents

- **Overview:** Currently there is no self-registration flow — users need to be created manually. A registration flow where the resident enters the condominium code (or is invited by the admin) would allow the product to scale.

- **Value for the User / Business:** Commercial viability of the product. Without this, each new condominium requires manual intervention.

- **Implementation Complexity:** **High**

- **Existing Files/Entities Used:**

- `User` model — `has_secure_password` already supports password creation

- `Condominium` model — would require `invite_code` or `slug`

- `SessionsController` — reference to the auth flow

- New: `RegistrationsController`, `InvitesController`

- **High-Level Implementation Plan:**

1. Generate a unique invitation token per condominium (or per email) — new `invitations` table

2. Admin sends invitation → email with link `GET /invitations/:token/accept`

3. Resident fills in name + password → `User.create!` associated with the condominium of the invitation

4. Redirect to dashboard after creation

5. Complete end-to-end testing of the flow

---

## Prioritization Summary

```
┌──────────────────────────────────────────────────────────┐
│ IMPACT │ EFFORT │ FEATURE   |                            │
├─────────────┼───────────────┼────────────────────────────┤
│ 🔴 CRITICAL │ Low │ 1. Edit/Delete Topics/Svcs           │
│ 🔴 CRITICAL │ Low │ 2. Profile Editing                   │
│ 🔴 CRITICAL │ Low-Medium │ 3. Email for Official Notices │
│ 🔴 HIGH │ Low │ 4. Resident's Public Profile             │
│ 🟡 MEDIUM │ Low-Medium │ 5. Content Search               │
│ 🟡 MEDIUM │ Low-Medium │ 6. Pagination                   │
│ 🟡 MEDIUM │ Low │ 7. Predefined Categories               │
│ 🟡 MEDIUM │ Medium │ 8. Reactions to Comments            │
│ 🟢 LOW │ Medium │ 9. Metrics Admin Panel                 │
│ 🟢 LOW │ High │ 10. In-App Notifications                 │
│ 🟢 LOW │ High │ 11. Self-registration/Invitations        │
└─────────────┴───────────────┴────────────────────────────┘
```

> [!IMPORTANT]

> Features 1, 2, and 3 are **quality prerequisites** for a solid MVP. I recommend implementing them before any engagement features. Feature 3 (emails for notifications) is especially strategic—it's the only push communication channel the product has today and is the biggest differentiator compared to WhatsApp groups.

> [!TIP]

> Feature 8 (reactions to comments) can be implemented **without any migration** using the existing polymorphic `Upvote`—simply adding the `upvotes_count` column to `comments`. This represents the lowest technical risk for a medium-impact engagement feature.

> [!NOTE]

> Feature 11 (self-registration) has the greatest impact on the product's growth potential, but it's also the most complex and should be planned separately with special attention to security and tenant isolation.