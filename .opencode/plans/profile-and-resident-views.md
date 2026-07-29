# Plan: Commit Profile & Resident Features

## Branch
`feat/profile-and-resident-pages` (from `main`)

## Commits (Option A)

### Commit 1: `feat: add email format validation and active_contributions to User`
- `app/models/user.rb`

### Commit 2: `feat: add profile edit page with password change`
- `app/controllers/profiles_controller.rb` (new)
- `app/views/profiles/edit.html.erb` (new)
- `app/javascript/controllers/password_toggle_controller.js` (new)
- `config/routes.rb` (full file — adds both profile + residents routes)
- `config/locales/en.yml` (full file — adds profiles + residents + not_found)
- `config/locales/pt-BR.yml` (full file)
- `config/locales/es.yml` (full file)
- `config/locales/ko.yml` (full file)

### Commit 3: `feat: add public resident profile page`
- `app/controllers/residents_controller.rb` (new)
- `app/views/residents/show.html.erb` (new)

### Commit 4: `feat: link author names to resident profiles`
- `app/views/layouts/application.html.erb`
- `app/views/dashboard/index.html.erb`
- `app/views/topics/show.html.erb`
- `app/views/topics/_comment.html.erb`

### Commit 5: `test: add profile and resident controller tests`
- `test/controllers/profiles_controller_test.rb` (new)
- `test/controllers/residents_controller_test.rb` (new)

## Execution
```bash
git checkout -b feat/profile-and-resident-pages
# commit 1
git add app/models/user.rb && git commit
# commit 2
git add app/controllers/profiles_controller.rb app/views/profiles/ app/javascript/controllers/password_toggle_controller.js config/routes.rb config/locales/ && git commit
# commit 3
git add app/controllers/residents_controller.rb app/views/residents/ && git commit
# commit 4
git add app/views/layouts/application.html.erb app/views/dashboard/index.html.erb app/views/topics/show.html.erb app/views/topics/_comment.html.erb && git commit
# commit 5
git add test/controllers/profiles_controller_test.rb test/controllers/residents_controller_test.rb && git commit
```

## Verification
- `bin/rails test` after each commit (optional, full suite at end)
- `bin/rubocop` after all commits
