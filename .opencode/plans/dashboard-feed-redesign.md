# Dashboard Feed Redesign — Implementation Plan

## Overview

Addresses all findings from the design critique of the discussion feed page. Focus: fix visual hierarchy (compose form eating viewport), add missing sort controls, fix pluralization bugs, improve affordances, and polish visual details.

## Dependency

> **This plan assumes the color unification plan (`unify-app-colors-with-landing.md`) has been applied first.**
> After that plan, the token landscape is:
> - `--primary-accent`: teal `#1A7A6D` (was blue)
> - `--secondary-accent`: coral `#E06B4F` (was indigo)
> - `--bg-primary`: paper `#F6F4F0` (was cool gray)
> - `--bg-tertiary`: warm gray `#EDEAE5` (was cool slate)
> - `--text-primary`: ink `#1A1D21` (was cool navy)
> - `--text-secondary`: ash `#64615A` (was cool gray)
> - `--text-muted`: warm muted `#9B9690` (was cool slate)
> - `--font-display`: `Space Grotesk` (was Outfit)
> - `--font-sans`: `DM Sans` (was Plus Jakarta Sans)
> - `.btn-primary`: solid coral (was blue→indigo gradient)
> - Focus rings: coral (was sky-blue)
>
> All CSS additions below use these warm tokens. Do NOT introduce cool-blue values.

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

**CSS additions** (`custom.css`):

```css
.compose-trigger {
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  border-radius: var(--radius-lg);
  padding: 1rem 1.5rem;
  color: var(--text-muted);
  font-size: 0.95rem;
  cursor: text;
  transition: border-color 0.2s, box-shadow 0.2s;
}

.compose-trigger:hover {
  border-color: var(--primary-accent);
}

.compose-trigger:focus-within {
  border-color: var(--primary-accent);
  box-shadow: 0 0 0 3px rgba(26, 122, 109, 0.15);
}
```

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

**CSS additions** (`custom.css`):

```css
.sort-controls {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.sort-link {
  padding: 0.4rem 0.8rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  color: var(--text-secondary);
  background: var(--bg-secondary);
  border: 1px solid var(--border-color);
  transition: background 0.2s, color 0.2s, border-color 0.2s;
}

.sort-link:hover {
  color: var(--text-primary);
  border-color: var(--primary-accent);
}

.sort-link.active {
  background: rgba(26, 122, 109, 0.12);
  color: var(--primary-accent);
  border-color: var(--primary-accent);
  font-weight: 600;
}
```

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

**CSS additions** (`custom.css`):

```css
.upvote-btn {
  /* Existing styles + enhancements */
  transition: background 0.2s, color 0.2s, border-color 0.2s, transform 0.15s;
}

.upvote-btn:hover {
  background: rgba(26, 122, 109, 0.12);
  color: var(--primary-accent);
  border-color: var(--primary-accent);
  transform: translateY(-1px);
}

.upvote-btn:active {
  transform: translateY(0) scale(0.95);
}

.upvote-btn.upvoted {
  background: var(--primary-accent);
  color: var(--bg-primary);
  border-color: var(--primary-accent);
}
```

> **Note:** The color unification plan already updates `.upvote-btn:hover` to teal. This section adds the interaction enhancements (scale, pressed state) on top.

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

**CSS additions** (`custom.css`):

```css
.search-input-wrapper {
  position: relative;
  flex: 1;
}

.search-input-wrapper .search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
  pointer-events: none;
  width: 16px;
  height: 16px;
}

.search-input-wrapper .form-input {
  padding-left: 2.75rem;
}
```

> **Note:** The search icon uses warm muted (`--text-muted`), not cool gray. The input focus ring uses teal (handled by color unification plan).

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

**CSS additions** (`custom.css`):

```css
.upvote-count {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--text-primary);
}

.post-footer-link {
  font-size: 0.85rem;
  color: var(--text-secondary);
  display: flex;
  align-items: center;
  gap: 0.4rem;
}

.post-footer-link:hover {
  color: var(--primary-accent);
}

.post-footer-link svg {
  width: 14px;
  height: 14px;
}
```

> **Note:** The upvote count uses warm ink (`--text-primary`). The comment link hover uses teal (`--primary-accent`).

**Modify:** `app/views/topics/_topic.html.erb`

- Replace `💬` emoji with a small inline SVG for the comment link

---

## 8. Button hierarchy + spacing normalization (CSS)

**Priority:** 🟢 Minor — visual rhythm

**Modify:** `app/assets/stylesheets/custom.css`

- `.creator-card` and `.post-card`: normalize to same padding (1.5rem)
- Search form: lighter treatment (no primary button competing with "Salvar")

**CSS additions** (`custom.css`):

```css
.creator-card,
.post-card {
  padding: 1.5rem;
}

.search-form {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.search-form .form-input {
  flex: 1;
}
```

> **Note:** After the color unification plan, `.btn-primary` is solid coral. The search form no longer has a competing primary button (replaced by icon-only search). The "Salvar" button remains the only coral CTA on the page, preserving visual hierarchy.

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

0. **Apply color unification plan first** (`unify-app-colors-with-landing.md`) — this plan's CSS additions assume warm tokens
1. Migration + model changes (comments_count, counter_cache)
2. Dashboard query sort logic
3. Controller sort param handling
4. Compose controller (Stimulus)
5. View updates (dashboard, topic partial)
6. CSS updates (sort controls, compose trigger, search icon, upvote enhancements, social proof, spacing)
7. Locale file updates
8. Tests
9. Run `bin/ci` to verify

---

## Notes

- Keep all changes backward-compatible (no breaking route changes)
- Preserve existing i18n structure
- Maintain dark mode support in all new CSS (use warm dark tokens: `--bg-primary: #1A1D21`, `--bg-secondary: #24272B`, `--bg-tertiary: #2E3136`, `--text-primary: #F6F4F0`, `--primary-accent: #2AB3A1`)
- Ensure mobile responsiveness for new sort controls
- Follow existing code conventions (see AGENTS.md)
- **All new CSS should use CSS custom properties, not hardcoded colors** — this ensures dark mode and future theme changes propagate automatically

---

## Overlap with Color Unification Plan

The color unification plan handles these items that also appear in this plan:

| Item | Color plan handles | This plan adds |
|---|---|---|
| Upvote hover color | Changes from blue to teal | Scale transform + pressed state |
| Tab active state | Changes from blue tint to teal tint | — (no structural change) |
| Focus rings | Changes from sky-blue to coral | — (no structural change) |
| `.btn-primary` | Changes from gradient to solid coral | — (no structural change) |
| Badge colors | Changes from green/red to teal/amber | — (no structural change) |

**Implementation strategy:** Apply the color plan first, then layer this plan's structural/interaction enhancements on top. The color plan changes *what* the colors are; this plan changes *how* elements behave and are laid out.
