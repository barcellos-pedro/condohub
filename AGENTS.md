# Agent Instructions for CondoHub

Rails 8.1 / Ruby 4.0.5 / SQLite / Hotwire (Turbo + Stimulus) / importmap + Propshaft.
For full architecture, see [CODEMAP.md](CODEMAP.md).

## Commands

```
bundle install
bin/setup --skip-server          # install deps + prepare DB (no server)
bin/rails test                   # full test suite
bin/rails test test/path/to_test.rb   # single test file
bin/rubocop                      # lint (rubocop-rails-omakase)
bin/ci                           # full CI pipeline (see below)
bin/rails db:migrate             # run pending migrations
env RAILS_ENV=test bin/rails db:test:prepare   # reset test DB to match schema
```

## CI pipeline

`bin/ci` runs these steps in order (defined in `config/ci.rb`):
1. `bin/setup --skip-server`
2. `bin/rubocop`
3. `bin/bundler-audit`
4. `bin/importmap audit`
5. `bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error`
6. `bin/rails test`
7. `env RAILS_ENV=test bin/rails db:seed:replant`

Run `bin/ci` before pushing to catch security issues and test failures together.

## Auth

Custom session-based auth in `app/controllers/concerns/authentication.rb`. Uses `Current.session` / `Current.user` (delegated via `ActiveSupport::CurrentAttributes`). Cookie: `cookies.signed[:session_id]`. **Do not add Devise or other auth gems.**

- `allow_unauthenticated_access` is a custom class method (not a Rails built-in) — use it to skip `require_authentication`.
- Sessions are rate-limited: `rate_limit to: 10, within: 3.minutes` on `SessionsController#create`.

## Multi-tenant scoping

Every authenticated controller scopes queries through `current_condominium` (derived from `current_user.condominium`). Cross-condo access raises `RecordNotFound` → 404. Always scope finds through `current_condominium.<association>`:

```ruby
# Correct — scoped to current user's condominium
@topic = current_condominium.topics.find(params[:id])

# Wrong — leaks cross-condo data
@topic = Topic.find(params[:id])
```

## I18n

4 locales: `en`, `pt-BR` (default), `es`, `ko`. All routes are locale-scoped (`/:locale/...`). `ApplicationController#default_url_options` always includes `locale:`, so URL helpers automatically preserve the current locale. See `config/locales/`.

## Routes

Locale-scoped under optional `(:locale)` with regex `/en|pt\-BR|es|ko/`. Resources: `session`, `passwords`, `dashboard`, `topics` (show/create/edit/update/destroy), `comments`, `upvotes`, `condominium` (show/edit/update, admin only), `service_listings` (create/edit/update/destroy), `profile`, `residents` (show). Follow existing nesting; don't add broad new routes.

## Frontend

Importmap-based — no bundler, no Webpack, no Vite. Stimulus controllers in `app/javascript/controllers/`, eager-loaded via `index.js`. Add new controllers there and they are auto-registered. Controllers: `theme`, `locale_switcher`, `password_toggle`, `cta_signup`, `hello`.

## Rails 8.1 conventions

- **Strong params**: Use `params.expect(resource: [...])` — NOT `params.require(...).permit(...)`.
- **Email normalization**: `normalizes :email_address, with: ->(e) { e.strip.downcase }` on User.
- **String-backed enums**: `enum :role, { resident: "resident", admin: "admin" }` — not integer-backed.
- **Custom inflection**: `condominium` → `condominiums` (see `config/initializers/inflections.rb`).
- **Browser gate**: `allow_browser versions: :modern` in ApplicationController.

## Domain rules

- **Announcements are admin-only**: `Topic` validates `announcements_only_by_admins`. Non-admin users can only create discussions.
- **Upvotes are polymorphic toggle**: `UpvotesController#create` toggles — creates if absent, destroys if present. `counter_cache: :upvotes_count` on `Upvote`.
- **`Searchable` concern**: `Topic` and `ServiceListing` include `Searchable`, providing `.search(query)` scope (SQL LIKE on declared fields).
- **`ServiceListing::CATEGORIES`**: Frozen constant array — add new categories here, not just in views/forms.
- **Owner/admin authorization**: `require_owner` in Topics checks admin for announcements, user_id for discussions. ServiceListings checks `user_id == current_user.id || current_user.admin?`.

## Testing

- Minitest with `fixtures :all` (loaded in `test/test_helper.rb`)
- Integration test auth helper: `sign_in_as(users(:one))` from `test/test_helpers/session_test_helper.rb`
- Parallel test execution enabled (`workers: :number_of_processors`)
- Upvotes fixture is intentionally empty to avoid conflicting with toggle tests
- After model/controller changes, run `bin/rails test` before committing
- Test DB reset: `env RAILS_ENV=test bin/rails db:seed:replant` reloads fixtures and seeds

## Commit conventions

Semantic commits: `<type>: <present-tense summary>`
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Deploy

Fly.io via `fly.toml` (app: `condohub-app`, region: `gru`). SQLite on persistent volume at `/data`. Production uses 4 separate SQLite DBs (app, cache, queue, cable). Dockerfile + Kamal config present. Production requires `RAILS_MASTER_KEY` and `SECRET_KEY_BASE` (see README).
