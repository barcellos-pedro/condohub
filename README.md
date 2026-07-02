# CondoHub

CondoHub is a Rails 8.1 web app for condominium residents to share updates, discuss community topics, and recommend local services. The product is intentionally simple and focuses on a small MVC structure with a custom, session-based authentication flow.

## What the app does

- Lets residents sign in and browse a community feed
- Supports discussions and announcements by condominium
- Allows residents to add service recommendations and receive vouches
- Uses a lightweight, Rails-native UI with Turbo and Stimulus

## Tech stack

- Ruby on Rails 8.1
- SQLite for development and test databases
- Hotwire (Turbo + Stimulus)
- Importmap and Propshaft for asset handling
- BCrypt for password hashing

## Prerequisites

- Ruby 3.2+ (matching the app version in the Gemfile)
- Bundler
- SQLite development libraries

## Local setup

Install dependencies and prepare the database:

```bash
bundle install
bin/setup --skip-server
```

Start the app:

```bash
bin/rails server
```

Then open http://localhost:3000.

## Running tests

Run the test suite:

```bash
bin/rails test
```

Reset the test database and reload fixture data:

```bash
env RAILS_ENV=test bin/rails db:seed:replant
```

Run the full CI-style checks:

```bash
bin/ci
```

## Project structure

- app/controllers contains the main request handling for sessions, topics, services, and the dashboard
- app/models holds the core domain models such as Condominium, User, Topic, Comment, Upvote, and ServiceListing
- app/javascript/controllers contains Stimulus controllers loaded through `config/importmap.rb`
- test contains controller, model, mailer, and integration tests
- config/routes.rb defines the intentionally narrow locale-scoped route set used by the app

## Notes for contributors

- Keep changes aligned with the existing Rails conventions and the custom auth flow in app/controllers/concerns/authentication.rb
- Prefer small, focused edits over broad refactors
- Follow the existing route and nesting patterns rather than introducing new abstractions unless they are clearly needed
