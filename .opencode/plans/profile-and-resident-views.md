# Profile Editing & Public Resident Profile

## Scope
- `/profile/edit` — logged-in user edits own name, email, password (requires current password)
- `/residents/:id` — public profile showing user's contributions (topics, comments, services, vouches)
- Header name becomes clickable link to profile
- Author names across site link to public profile

## Files to Create
- `app/controllers/profiles_controller.rb`
- `app/controllers/residents_controller.rb`
- `app/views/profiles/edit.html.erb`
- `app/views/residents/show.html.erb`
- `test/controllers/profiles_controller_test.rb`
- `test/controllers/residents_controller_test.rb`

## Files to Modify
- `app/models/user.rb` — add email format validation + `active_contributions` method
- `config/routes.rb` — add profile and residents routes
- `app/views/layouts/application.html.erb` — link header name to profile
- `app/views/dashboard/index.html.erb` — link author names (3 locations)
- `app/views/topics/show.html.erb` — link author name
- `app/views/topics/_comment.html.erb` — link commenter name
- `config/locales/en.yml`, `pt-BR.yml`, `es.yml`, `ko.yml` — add i18n keys

## Implementation Details

### 1. User Model (`app/models/user.rb`)
Add email format validation and `active_contributions` method:
```ruby
validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

def active_contributions
  {
    topics: topics.count,
    comments: comments.count,
    services: service_listings.count,
    vouches: upvotes.count
  }
end
```

### 2. ProfilesController (`app/controllers/profiles_controller.rb`)
```ruby
class ProfilesController < ApplicationController
  before_action :require_authentication

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

### 3. ResidentsController (`app/controllers/residents_controller.rb`)
```ruby
class ResidentsController < ApplicationController
  before_action :require_authentication

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

### 4. Routes (`config/routes.rb`)
Add inside locale scope:
```ruby
resource :profile, only: [:edit, :update]
resources :residents, only: [:show]
```

### 5. Profile Edit View (`app/views/profiles/edit.html.erb`)
- Match existing card style (thread-card, form-group, btn classes)
- Toggle password section (hidden by default, Stimulus controller to show/hide)
- Fields: first_name, last_name, email_address
- Password section: current_password, password, password_confirmation

### 6. Resident Show View (`app/views/residents/show.html.erb`)
- Display resident name, role, contribution stats
- Recent topics list (linked)
- Recent comments list
- Services listed

### 7. Header Link (`app/views/layouts/application.html.erb:63`)
Change:
```erb
<div class="user-nav-name"><%= current_user.full_name %></div>
```
To:
```erb
<div class="user-nav-name"><%= link_to current_user.full_name, edit_profile_path, class: "profile-link" %></div>
```

### 8. Author Links
Wrap `full_name` in `link_to resident_path(user)` in:
- `app/views/dashboard/index.html.erb` lines 76, 137, 189
- `app/views/topics/show.html.erb` line 11
- `app/views/topics/_comment.html.erb` line 5

### 9. Locale Strings
Add to all 4 locale files:
- `profiles.edit.*` (title, name, email, current_password, new_password, confirm_password, change_password, save, updated, wrong_password)
- `residents.show.*` (title, topics, comments, services, vouches, recent_activity, no_topics, no_comments, no_services)
- `not_found` (flash message)

### 10. Tests

#### `test/controllers/profiles_controller_test.rb`
- Profile update with valid data succeeds
- Profile update with duplicate email fails
- Password change requires current password
- Password change with wrong current password fails

#### `test/controllers/residents_controller_test.rb`
- Public profile shows correct resident data
- Accessing resident from different condominium redirects to dashboard

## Test Requirements
- Profile update with valid data succeeds
- Profile update with duplicate email fails
- Password change requires current password
- Public profile shows correct resident data
- Accessing resident from different condominium returns redirect to dashboard

## Verification
Run:
```bash
bin/rails test test/controllers/profiles_controller_test.rb
bin/rails test test/controllers/residents_controller_test.rb
bin/rails test
bin/rubocop
```
