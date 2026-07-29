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
bin/ci                           # full CI: setup, rubocop, bundler-audit, importmap audit, brakeman, tests, seed replant
env RAILS_ENV=test bin/rails db:seed:replant   # reset test DB + reload fixtures
```

## Auth

Custom session-based auth in `app/controllers/concerns/authentication.rb`. Uses `Current.session` / `Current.user` via `ActiveSupport::CurrentAttributes`. Cookie: `cookies.signed[:session_id]`. **Do not add Devise or other auth gems.**

## Multi-tenant scoping

Every authenticated controller scopes queries through `current_condominium` (derived from `current_user.condominium`). Cross-condo access raises `RecordNotFound` → 404. Always scope finds through `current_condominium.<association>`.

## I18n

4 locales: `en`, `pt-BR` (default), `es`, `ko`. All routes are locale-scoped (`/:locale/...`). `default_url_options` always includes `locale:`. See `config/locales/`.

## Routes

Locale-scoped under optional `(:locale)` with regex `/en|pt\-BR|es|ko/`. Resources: `session`, `passwords`, `dashboard`, `topics` (show/create/edit/update/destroy), `comments`, `upvotes`, `condominium` (admin), `service_listings` (create/edit/update/destroy), `profile`, `residents` (show). Follow existing nesting; don't add broad new routes.

## Frontend

Importmap-based — no bundler, no Webpack, no Vite. Stimulus controllers in `app/javascript/controllers/`, eager-loaded via `index.js`. Add new controllers there and they are auto-registered. Controllers: `theme`, `locale_switcher`, `password_toggle`, `cta_signup`.

## Testing

- Minitest with `fixtures :all` (loaded in `test/test_helper.rb`)
- Integration test auth helper: `sign_in_as(users(:name))` from `test/test_helpers/session_test_helper.rb`
- Parallel test execution enabled (`workers: :number_of_processors`)
- After model/controller changes, run `bin/rails test` before committing

## Commit conventions

Semantic commits: `<type>: <present-tense summary>`
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Deploy

Fly.io via `fly.toml` (app: `condohub-solitary-shape-2752`, region: `gru`). SQLite on persistent volume at `/data`. Dockerfile + Kamal config present.
