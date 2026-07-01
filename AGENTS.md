# Agent Instructions for Condo

## Purpose

This repository is a Ruby on Rails 8.1 application with a small MVC structure and a custom, session-based authentication flow. Agents should favor Rails-native patterns, keep changes minimal, and follow the existing conventions in the app.

## What to know first

- Start with [README.md](README.md) and [database_architecture.md](database_architecture.md) for setup context.
- The app uses Rails importmap, propshaft, Turbo, and Stimulus; avoid introducing extra JavaScript tooling unless the task explicitly requires it.
- Authentication is custom and lives in [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb). Keep any auth-related changes consistent with the existing `Current.session` and `Current.user` flow rather than introducing Devise or another library.
- Routes are intentionally narrow in [config/routes.rb](config/routes.rb); prefer the existing nested resource structure over broad new routes.

## Recommended commands

- `bundle install`
- `bin/setup --skip-server`
- `bin/rails test`
- `bin/ci`
- `env RAILS_ENV=test bin/rails db:seed:replant`

## Project conventions

- Use the existing domain model names and associations: `Condominium`, `User`, `Topic`, `Comment`, `Upvote`, `ServiceListing`, and `Session`.
- Follow Rails MVC structure and keep changes scoped to the relevant model, view, controller, or test file.
- Add or update tests with Minitest and fixtures from [test/test_helper.rb](test/test_helper.rb); prefer covering behavior at the controller/model level when that is the affected layer.
- Keep auth, session, and routing changes aligned with [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb) and [config/routes.rb](config/routes.rb).
- Prefer minimal, context-aware edits over broad refactors or new abstractions.

## Useful references

- [README.md](README.md)
- [database_architecture.md](database_architecture.md)
- [config/ci.rb](config/ci.rb)
- [config/routes.rb](config/routes.rb)
- [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb)
- [app/models/user.rb](app/models/user.rb)
- [app/controllers/application_controller.rb](app/controllers/application_controller.rb)
