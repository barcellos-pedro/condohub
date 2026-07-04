# Agent Instructions for Condo

## Purpose

This repository is a Ruby on Rails 8.1 application with a small MVC structure and a custom, session-based authentication flow. Agents should favor Rails-native patterns, keep changes minimal, and follow existing app conventions.

## What to know first

- Start with [README.md](README.md) and [database_architecture.md](database_architecture.md) for setup context.
- The app uses Rails importmap, Propshaft, Turbo, and Stimulus; avoid introducing extra JavaScript tooling unless the task explicitly requires it.
- Authentication is custom and centralized in [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb). Keep changes aligned with the `Current.session` / `Current.user` flow and avoid Devise or other auth libraries.
- Routes are intentionally narrow in [config/routes.rb](config/routes.rb). Use the existing locale-scoped, nested resource structure instead of broad new routes.
- Frontend behavior is built with Hotwire: [app/javascript/application.js](app/javascript/application.js) and [config/importmap.rb](config/importmap.rb) load Turbo and Stimulus controllers.

## Recommended commands

- `bundle install`
- `bin/setup --skip-server`
- `bin/rails test`
- `bin/ci`
- `env RAILS_ENV=test bin/rails db:seed:replant`

## Project conventions

- Use the existing domain model names and associations: `Condominium`, `User`, `Topic`, `Comment`, `Upvote`, `ServiceListing`, and `Session`.
- Follow Rails MVC structure and keep changes scoped to the relevant model, view, controller, or test file.
- Add or update tests with Minitest and fixtures from [test/test_helper.rb](test/test_helper.rb); prefer controller/model tests when behavior changes.
- Keep auth, session, and routing changes aligned with [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb) and [config/routes.rb](config/routes.rb).
- Prefer small, focused edits over broad refactors or new abstractions.
- Respect the app's importmap-based JS stack and avoid adding bundlers, Webpack, Vite, or similar unless explicitly requested.

## CI and test flow

- `bin/ci` runs setup, RuboCop, Bundler Audit, Importmap audit, Brakeman, Rails tests, and test seed replant.
- `bin/rails test` is the preferred local test command.
- Test fixtures are loaded globally from [test/test_helper.rb](test/test_helper.rb) with `fixtures :all`.
- Database seeding for test resets is `env RAILS_ENV=test bin/rails db:seed:replant`.

## Commit conventions

Use semantic commit messages with one of these types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`. Follow the format:

```
<type>: <present-tense summary>
```

Examples:
- `feat: add hat wobble`
- `fix: resolve sign-in redirect loop`
- `docs: update API endpoint docs`
- `refactor: extract payment calculation`
- `test: add coverage for upvote model`
- `chore: bump brakeman to 7.0`

## Useful references

- [README.md](README.md)
- [database_architecture.md](database_architecture.md)
- [config/ci.rb](config/ci.rb)
- [config/routes.rb](config/routes.rb)
- [config/importmap.rb](config/importmap.rb)
- [app/controllers/concerns/authentication.rb](app/controllers/concerns/authentication.rb)
- [app/javascript/application.js](app/javascript/application.js)
- [app/javascript/controllers/index.js](app/javascript/controllers/index.js)

## Suggested next customizations for agents

- Add a focused agent instruction for testing workflows and common `bin/ci` maintenance tasks.
- Add a small frontend skill documenting Stimulus controller locations and importmap conventions.
