# Unify App Colors & Look-and-Feel with Landing Page

## Problem

The landing page and the authenticated app look like two different products:

| | Landing | App |
|---|---|---|
| **Palette** | Warm: teal `#1A7A6D`, coral `#E06B4F`, paper `#F6F4F0`, ink `#1A1D21` | Cool: blue `#0284c7`, indigo `#6366f1`, cool gray `#f8fafc` |
| **Typography** | `DM Sans` (body) + `Space Grotesk` (display) | `Plus Jakarta Sans` (body) + `Outfit` (display) |
| **Background** | White/paper, no gradients | Cool gray + radial gradient blobs (indigo/sky) |
| **Buttons** | Solid coral, warm shadows | Blue→indigo gradient, cool shadows |
| **Logo** | Solid teal text | Gradient text (white→blue) |
| **Borders** | Warm `#E8E6E1` | Cool `rgba(0,0,0,0.08)` |
| **Feel** | Organic, editorial, approachable | Techy, SaaS, generic |

---

## Token Mapping

Replace every cool token in `custom.css` with its warm landing equivalent:

### Light mode (`:root`)

| Token | Current (cool) | New (warm, from landing) |
|---|---|---|
| `--bg-primary` | `#f8fafc` | `#F6F4F0` (paper) |
| `--bg-secondary` | `#ffffff` | `#FFFFFF` (keep) |
| `--bg-tertiary` | `#f1f5f9` | `#EDEAE5` (warm gray) |
| `--border-color` | `rgba(0,0,0,0.08)` | `#E8E6E1` |
| `--text-primary` | `#0f172a` | `#1A1D21` (ink) |
| `--text-secondary` | `#64748b` | `#64615A` (ash) |
| `--text-muted` | `#94a3b8` | `#9B9690` (warm muted) |
| `--primary-accent` | `#0284c7` | `#1A7A6D` (teal) |
| `--primary-accent-hover` | `#0369a1` | `#145A51` (teal-dark) |
| `--secondary-accent` | `#6366f1` | `#E06B4F` (coral) |
| `--font-sans` | `'Plus Jakarta Sans'` | `'DM Sans'` |
| `--font-display` | `'Outfit'` | `'Space Grotesk'` |
| `--shadow-sm` | `rgba(0,0,0,0.06)` | `rgba(26,29,33,0.06)` |
| `--shadow-md` | `rgba(0,0,0,0.08)` | `rgba(26,29,33,0.08)` |
| `--shadow-lg` | `rgba(0,0,0,0.12)` | `rgba(26,29,33,0.12)` |
| `--app-header-bg` | `rgba(255,255,255,0.8)` | `rgba(255,255,255,0.95)` (match landing header) |

### Dark mode (`[data-theme="dark"]`)

Rework from cool blue-dark to warm ink-dark:

| Token | Current (cool) | New (warm) |
|---|---|---|
| `--bg-primary` | `#0b0f19` | `#1A1D21` (ink as bg) |
| `--bg-secondary` | `#131a2e` | `#24272B` |
| `--bg-tertiary` | `#1b2542` | `#2E3136` |
| `--border-color` | `rgba(255,255,255,0.08)` | `rgba(255,255,255,0.08)` (keep) |
| `--text-primary` | `#f3f4f6` | `#F6F4F0` (paper) |
| `--text-secondary` | `#9ca3af` | `#A8A49E` (warm) |
| `--text-muted` | `#6b7280` | `#7A7670` (warm) |
| `--primary-accent` | `#38bdf8` | `#2AB3A1` (bright teal) |
| `--primary-accent-hover` | `#0ea5e9` | `#1A7A6D` (teal) |
| `--secondary-accent` | `#6366f1` | `#E06B4F` (coral, keep) |
| `--app-header-bg` | `rgba(19,26,46,0.8)` | `rgba(26,29,33,0.95)` |

---

## Component-Specific Changes

### 1. Font loading (`app/views/layouts/application.html.erb`)

Add Google Fonts preconnect + link (same as landing layout line 29-31):
```erb
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet">
```

### 2. Google Fonts import in `custom.css`

Replace line 2:
```css
/* Old */
@import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap');
/* New */
@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=DM+Sans:wght@400;500;600&display=swap');
```

### 3. Body background

Remove the cool radial gradients. Replace with landing-style subtle warm gradient or solid paper:
```css
body {
  background-color: var(--bg-primary);
  /* Remove the two radial-gradient blobs */
}
```

### 4. Logo (`.logo`)

Replace gradient text with solid teal (matching landing):
```css
.logo {
  /* Remove: background, -webkit-background-clip, -webkit-text-fill-color */
  color: var(--teal); /* or var(--primary-accent) */
}
```

### 5. Primary button (`.btn-primary`)

Replace blue→indigo gradient with solid coral (matching landing CTA):
```css
.btn-primary {
  background: var(--coral); /* #E06B4F */
  /* Remove: linear-gradient */
}
.btn-primary:hover {
  background: var(--coral-hover); /* #D45A3E */
  box-shadow: var(--shadow-md);
}
```

### 6. Tab active state (`.tab-link.active`)

Replace blue tint with teal tint:
```css
.tab-link.active {
  color: var(--primary-accent); /* now teal */
  background: rgba(26, 122, 109, 0.08); /* teal tint, not blue */
}
```

### 7. Upvote active (`.upvote-btn.upvoted`)

Already uses `--primary-accent`, so it auto-updates to teal. No change needed.

### 8. Focus rings

Replace sky-blue focus with coral focus (matching landing):
```css
/* All focus-visible rules */
outline: 3px solid rgba(224, 107, 79, 0.4); /* coral, not sky-blue */
```

### 9. Badges

- `.badge-resident`: change from green to teal-based:
  ```css
  background: rgba(26, 122, 109, 0.12);
  color: var(--teal);
  border: 1px solid rgba(26, 122, 109, 0.25);
  ```
- `.badge-admin`: keep warm red (already close to landing's amber staff badge). Update to match landing's `badge-staff` style:
  ```css
  background: rgba(217, 119, 6, 0.12);
  color: #92400e;
  border: 1px solid rgba(217, 119, 6, 0.25);
  ```
- `.badge-announcement`: already warm amber, keep as-is.

### 10. Locale select hover

Replace blue hover with teal:
```css
.locale-select:hover {
  border-color: var(--primary-accent); /* teal */
  background: rgba(26, 122, 109, 0.05);
}
```

### 11. Upvote button hover

Replace blue hover with teal:
```css
.upvote-btn:hover {
  background: rgba(26, 122, 109, 0.12);
  color: var(--primary-accent);
  border-color: var(--primary-accent);
}
```

### 12. Form input focus

Replace blue focus ring with teal:
```css
.form-input:focus-visible {
  border-color: var(--primary-accent);
  box-shadow: 0 0 0 3px rgba(26, 122, 109, 0.15);
}
```

### 13. Service category badge

Replace indigo with teal:
```css
.service-category {
  background: rgba(26, 122, 109, 0.12);
  color: var(--teal); /* or --primary-accent */
}
```

### 14. Vouch button

Replace green with teal:
```css
.btn-vouch {
  background: rgba(26, 122, 109, 0.08);
  color: var(--primary-accent);
  border: 1px solid rgba(26, 122, 109, 0.2);
}
.btn-vouch:hover {
  background: var(--primary-accent);
  box-shadow: 0 4px 12px rgba(26, 122, 109, 0.2);
}
```

### 15. Dark mode background gradients

Replace cool indigo/sky gradients with warm teal/coral:
```css
[data-theme="dark"] body {
  background-image:
    radial-gradient(at 0% 0%, rgba(26, 122, 109, 0.1) 0px, transparent 50%),
    radial-gradient(at 100% 0%, rgba(224, 107, 79, 0.08) 0px, transparent 50%);
}
```

### 16. Flash notice

Replace green with teal:
```css
.flash-notice {
  background: rgba(26, 122, 109, 0.12);
  color: var(--primary-accent);
  border: 1px solid rgba(26, 122, 109, 0.25);
}
```

### 17. WhatsApp link

Keep `#25D366` — it's the WhatsApp brand color, not ours to change.

### 18. Error code gradient

Replace blue→indigo with teal→coral:
```css
.error-code {
  background: linear-gradient(135deg, var(--primary-accent) 0%, var(--secondary-accent) 100%);
  /* Now teal→coral instead of blue→indigo */
}
```

### 19. Skip link

Replace blue with coral:
```css
.skip-link {
  background: var(--secondary-accent); /* coral */
}
```

### 20. Login card, impersonation section

No structural changes needed — they inherit from CSS variables, so they auto-update.

---

## Files Changed

| File | Change |
|---|---|
| `app/views/layouts/application.html.erb` | Add Google Fonts preconnect + link for DM Sans + Space Grotesk |
| `app/assets/stylesheets/custom.css` | Replace all color tokens, font variables, gradients, and component-specific overrides |

That's it — **2 files**. Everything else (views, components) inherits from CSS custom properties.

---

## Implementation Order

1. Add font link to `application.html.erb`
2. Update `@import` in `custom.css`
3. Update `:root` custom properties
4. Update `[data-theme="dark"]` custom properties
5. Update body background (remove cool gradients)
6. Update component-specific rules (logo, buttons, badges, focus rings, etc.)
7. Run `bin/rails test` to verify no breakage
8. Run `bin/rubocop` for good measure

---

## What Does NOT Change

- All HTML/view templates (they inherit from CSS variables)
- All Stimulus controllers
- All models, controllers, routes
- All locale files
- WhatsApp brand color
- Landing page (already the source of truth)
- Dark mode toggle logic (just the colors it switches to)

---

## Verification

After changes:
1. Open landing page → note the warm teal/coral/paper feel
2. Click "Get Started" → app dashboard should feel like a continuation of the same product
3. Toggle dark mode → warm dark, not cool blue-dark
4. Check all pages: login, dashboard, topic show, profile edit, condo settings, services
5. Run `bin/rails test` — no test should break (CSS-only changes)
