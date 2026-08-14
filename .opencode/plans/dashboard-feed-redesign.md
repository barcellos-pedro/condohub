# Dashboard Feed Redesign — Implementation Plan

## Overview

Addresses all findings from the design critique of the discussion feed page. Focus: fix visual hierarchy (compose form eating viewport), add missing sort controls, fix pluralization bugs, improve affordances, and polish visual details.

---

## 1. Collapse compose form into single-line trigger (Critical)

**Priority:** 🔴 High — fixes the main hierarchy problem

**New file:** `app/javascript/controllers/compose_controller.js`

- Stimulus controller with `trigger` and `form` targets
- Click/focus on trigger → hides trigger, reveals full form, focuses first input
- Cancel button collapses back
- Auto-expands if form has validation errors (checks for `.form-error`)

**Modify:** `app/views/dashboard/index.html.erb`

- Wrap each tab's form in a `compose`-scoped container with collapsed trigger + hidden form
- Three instances: discussions, announcements (admin), services
- Trigger text uses i18n placeholder ("Compartilhe algo com a vizinhança...")

---

## 2. Add sort controls for discussions and services

**Priority:** 🟡 Moderate — won't scale without it

**Modify:** `app/controllers/dashboard_controller.rb`

- Read `params[:sort]`, validate against allowed values per tab
- Pass to `Dashboard.query`

**Modify:** `app/models/dashboard.rb`

- Accept `sort:` keyword argument
- Discussions: `"popular"` (default, current), `"recent"`, `"unanswered"` (comments_count = 0)
- Services: `"popular"` (default), `"recent"`
- Announcements: no sort (always `created_at: :desc`)

**New migration:** Add `comments_count` integer (default 0) to `topics` table

- Enables "unanswered" sort and fixes N+1 in `_topic.html.erb`
- Backfill existing counts
- Add `counter_cache: :comments_count` to `Comment.belongs_to :topic`

**Modify:** `app/views/dashboard/index.html.erb`

- Add sort row between search form and feed (pill-style links)
- Only shown on discussions and services tabs

---

## 3. Fix comment count pluralization

**Priority:** 🟢 Minor — grammar fix

**Modify:** `app/views/topics/_topic.html.erb`

- Replace `topic.comments.count` with `topic.comments_count` (uses new counter_cache)
- Replace static `"comentários"` with `t("dashboard.index.comments_count", count: topic.comments_count)`

**Modify:** all 4 locale files (`pt-BR`, `en`, `es`, `ko`)

- Add `comments_count` key with `one`/`other` pluralization under `dashboard.index`

---

## 4. Improve upvote affordance (CSS)

**Priority:** 🟡 Moderate — currently reads as inert

**Modify:** `app/assets/stylesheets/custom.css`

- Add `cursor: pointer` emphasis, scale transform on hover
- Add subtle color transition on `.upvote-btn`
- Add a pressed/active state animation

---

## 5. Search: icon-only inside input, remove standalone button

**Priority:** 🟢 Minor — UX polish

**Modify:** `app/views/dashboard/index.html.erb`

- Replace search form's submit button with an SVG search icon inside the input wrapper
- Form submits on Enter
- Preserve `sort` and `category` params as hidden fields

**Modify:** `app/assets/stylesheets/custom.css`

- Add `.search-input-wrapper` with relative positioning
- Position SVG icon absolutely inside the input

---

## 6. Sidebar: replace emoji icons with SVGs in tab nav

**Priority:** 🟢 Minor — consistency

**Modify:** `app/views/dashboard/index.html.erb`

- Remove emoji from tab link text, add inline SVGs (matching WhatsApp SVG pattern)
- Use simple stroke icons: chat bubble for discussions, megaphone for announcements, wrench for services

**Modify:** locale files

- Remove emoji from `discussions_tab`, `announcements_tab`, `services_tab` values

---

## 7. Social proof emphasis (CSS + view)

**Priority:** 🟡 Moderate — makes feed feel alive

**Modify:** `app/assets/stylesheets/custom.css`

- `.upvote-count`: increase font-weight, use `--text-primary` color
- `.post-footer-link`: slightly larger, add icon styling

**Modify:** `app/views/topics/_topic.html.erb`

- Replace `💬` emoji with a small inline SVG for the comment link

---

## 8. Button hierarchy + spacing normalization (CSS)

**Priority:** 🟢 Minor — visual rhythm

**Modify:** `app/assets/stylesheets/custom.css`

- `.creator-card` and `.post-card`: normalize to same padding (1.5rem)
- Search form: lighter treatment (no primary button competing with "Salvar")

---

## 9. Tests

**Modify:** `test/models/dashboard_test.rb` — add sort tests
**Modify:** `test/controllers/dashboard_controller_test.rb` — add sort param tests
**Add:** migration test for comments_count backfill

---

## Files changed (summary)

| File | Change |
| ------ | -------- |
| `app/javascript/controllers/compose_controller.js` | **New** — Stimulus controller |
| `app/views/dashboard/index.html.erb` | Collapse compose, sort controls, search icon, tab SVGs |
| `app/views/topics/_topic.html.erb` | Use `comments_count`, pluralized i18n, SVG comment icon |
| `app/controllers/dashboard_controller.rb` | Accept `sort` param |
| `app/models/dashboard.rb` | Accept `sort:`, add sort logic |
| `app/models/comment.rb` | Add `counter_cache: :comments_count` |
| `app/assets/stylesheets/custom.css` | Upvote, search, social proof, spacing, sort controls |
| `config/locales/{pt-BR,en,es,ko}.yml` | Pluralization keys, sort labels, remove emoji from tabs |
| `db/migrate/*_add_comments_count_to_topics.rb` | **New** — migration + backfill |
| `test/models/dashboard_test.rb` | Sort tests |
| `test/controllers/dashboard_controller_test.rb` | Sort param tests |

---

## Implementation order

1. Migration + model changes (comments_count, counter_cache)
2. Dashboard query sort logic
3. Controller sort param handling
4. Compose controller (Stimulus)
5. View updates (dashboard, topic partial)
6. CSS updates
7. Locale file updates
8. Tests
9. Run `bin/ci` to verify

---

## Notes

- Keep all changes backward-compatible (no breaking route changes)
- Preserve existing i18n structure
- Maintain dark mode support in all new CSS
- Ensure mobile responsiveness for new sort controls
- Follow existing code conventions (see AGENTS.md)
