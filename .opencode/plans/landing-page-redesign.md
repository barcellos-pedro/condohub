# Landing Page Redesign: "The Digital Notice Board"

## Overview

**Subject**: CondoHub — community platform for residential condominiums  
**Audience**: Brazilian/Latin American residents and building admins  
**Page job**: Convert visitors to signups  
**Product status**: Live product (unified CTA: "Começar")

---

## Core Concept

The physical notice board in condo lobbies — where staff pin announcements, residents leave notes, service contacts get taped up — is the analog version of what CondoHub digitizes. The landing page uses this as its visual anchor: a modern, layered card composition showing *real content* (not grey bars) arranged like notices on a board.

---

## Token System

### Color Palette (6 named values)

| Name | Hex | Role |
| ------ | ----- | ------ |
| **Teal** | `#1A7A6D` | Primary brand — logo, headings, nav. Connects to existing favicon teal (#20B2AA) but deeper. |
| **Coral** | `#E06B4F` | CTA buttons only — warm, urgent, high contrast against teal. |
| **Ink** | `#1A1D21` | Primary text — cool near-black. |
| **Ash** | `#64615A` | Secondary text — warm grey. |
| **Paper** | `#F6F4F0` | Alternating section backgrounds — warm off-white, like paper/concrete. |
| **White** | `#FFFFFF` | Primary background — clean, confident. |

### Typography (2 roles)

| Role | Face | Why |
|------|------|-----|
| **Display** | Space Grotesk | Geometric, modern, slightly quirky — distinctive without being weird. Tight tracking at large sizes. NOT the typical AI serif choice. |
| **Body** | DM Sans | Clean, readable, excellent Portuguese diacritics support, good x-height. |

### Layout

- **Hero**: Left-aligned headline + subhead + CTA on left; signature card composition on right. Breaks the centered-hero template.
- **Feature sections**: Consistent text-left / mockup-right layout (no more alternating sides — the critique says they blur together). Separated by alternating white → paper backgrounds.
- **Bottom CTA**: Centered, single "Começar" button — no email form.

### Signature Element

**The "Notice Board"** — 3 cards (discussion, announcement, service) in a slightly overlapping, pinned composition in the hero. Each card shows real seed data content:

1. **"Chaves perdidas na academia"** — discussion with upvote count
2. **"Manutenção da caixa d'água"** — announcement with STAFF badge  
3. **"Dona Maria's Cleaning — 8 recomendações"** — service card

Cards have subtle paper quality (light warm bg, soft shadow, tiny pin dots at top).

### Motion

- Hero cards: staggered entrance (fade-up + slight rotation, like being pinned)
- Feature sections: fade-in on scroll via IntersectionObserver (new Stimulus controller)
- Card hover: subtle lift + shadow
- All respects `prefers-reduced-motion`

---

## CTA Unification (Live Product)

| Location | Current | New |
| ---------- | --------- | ----- |
| Nav | "Começar" | "Começar" (unchanged) |
| Hero | "Junte-se à Sua Comunidade" | "Começar" |
| Bottom | "Solicitar Acesso" (email form) | "Começar" (simple button, no form) |

All link to `dashboard_path` (signup flow).

---

## Files to Change

1. **`app/assets/stylesheets/landing.css`** — Full rewrite: new tokens, Space Grotesk + DM Sans, left-aligned hero, card composition styles, alternating section backgrounds, scroll-reveal animations
2. **`app/views/layouts/landing.html.erb`** — Add Space Grotesk + DM Sans Google Fonts, update header CTA text
3. **`app/views/landing/index.html.erb`** — Restructure hero (left-aligned + card composition), replace grey-bar mockups with real-content mockups, restructure bottom CTA (remove email form)
4. **`config/locales/{pt-BR,en,es,ko}.yml`** — Unify CTA copy (`join_community` → reuse `get_started`), add new copy for hero card content, update bottom CTA
5. **New: `app/javascript/controllers/scroll_reveal_controller.js`** — IntersectionObserver for feature section fade-in

---

## What Stays the Same

- Favicon (already teal, fits the new palette)
- Locale switcher behavior
- Overall page structure (hero → 3 features → CTA → footer)
- All I18n infrastructure
- `cta_signup_controller.js` (kept but no longer used on landing — could be removed or left for future use)

---

## Design Principles Applied

- **Distinctive point of view**: Teal + coral palette breaks from the purple/indigo SaaS template
- **Subject-grounded**: Notice board metaphor directly reflects the product's purpose
- **Real content over placeholders**: Seed data content in hero cards, not grey bars
- **Left-aligned hero**: Breaks the centered-hero template for visual interest
- **Consistent structure**: All feature sections follow same left-right pattern for scannability
- **Motion with purpose**: Staggered card entrance reinforces the "pinning" metaphor
- **Accessibility**: Keyboard focus visible, reduced motion respected, color contrast checked

---

## Priority Recommendations from Critique (Addressed)

1. ✅ **Unify CTA strategy** — All CTAs now say "Começar" and link to signup
2. ✅ **Add visual variation between feature sections** — Alternating white/paper backgrounds
3. ✅ **Flesh out mock UI screenshots** — Real seed data content in hero cards and feature mockups
