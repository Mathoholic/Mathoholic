# Mathoholic — UI Research & Improvement Plan

**Date:** March 2026  
**Scope:** Current UI audit and planned improvements for the personal blog/portfolio (Jekyll, Garth-style theme).

---

## 1. Current UI — Research Summary

### 1.1 Layout & Structure

| Area | Current state |
|------|----------------|
| **Header** | Logo (SVG “SHANTANU MATHOHOLIC” / `{}` style) left; nav (About Me, Blog) + theme toggle right. Single breakpoint at **640px**: below = stacked (column, centered); above = row, space-between. |
| **Main** | Home: two-column at ≥640px — hero (left, fixed 280px flex) + recent posts (right, border-left divider). Blog/post/page: single column, centered. |
| **Container** | `width: 90%`, `max-width: 1000px`, margin auto. |
| **Footer** | Copyright + RebuildHQ link; social icons (Facebook, Threads, LinkedIn, Instagram). Same breakpoint behaviour as header. |

### 1.2 Typography

- **Fonts:** Alegreya Sans (body), Neuton (headings) — Google Fonts.
- **Scale:** Sassline modular scale; body ~zeta size; headings alpha→zeta; baseline grid.
- **Prose:** Post body `max-width: 70ch`; blog listing `max-width: 680px`. Readable line length.
- **Hero:** H1 1.9rem, lead 0.9rem, max-width 24ch.

### 1.3 Colour & Theming

- **Light:** “Monochrome Elite” — white bg, grays (#4A5568 body, #2D3748 heading, #1A202C link). Very low chroma.
- **Dark:** Slate palette (e.g. #1A202C bg, #90CDF4 link, #F7FAFC heading). CSS custom properties; `data-theme="dark"`; localStorage + `prefers-color-scheme`; inline script to avoid flash.
- **Links:** Gradient underline in `.typeset`; many `background-image: none !important` overrides to remove it on nav/buttons.

### 1.4 Components

- **Nav:** Inline items, 1rem gap; current page = heading colour + 2px link-colour underline.
- **Theme toggle:** Pill (2rem radius), moon/sun symbols, `role="switch"`, `aria-checked`.
- **Hero CTAs:** Pill buttons, border only, hover = link colour.
- **Post cards (home/blog):** Title, meta (date, read time, tags), excerpt, “Read article →”.
- **Pagination:** “← Previous | Page X of Y | Next →” when paginated.
- **Code:** Left border accent (3px link colour), inline code with subtle background.

### 1.5 Responsiveness

- **Breakpoints (Sassline):** 0, 640px, 800px, 1024px, 1600px. Theme uses mainly **break-1 (640px)**.
- **Mobile:** Header/nav/footer stack vertically; hero and recent posts stack (no left border on small screens).
- **Touch:** No explicit touch targets; tap areas are link/button default.

### 1.6 Accessibility

- Theme toggle has `role="switch"` and `aria-checked`; script syncs state.
- Social links have `aria-label`.
- Semantic structure (header, main, nav, article) and headings in order.
- Focus styles: not explicitly enhanced (rely on browser default).

### 1.7 Observed Pain Points (from code & description)

1. **Light mode link contrast** — Link colour #1A202C on white is subtle; may fail WCAG AA for normal text.
2. **Redundant navigation** — “About Me” and “Blog” in both header and hero; LinkedIn in hero and footer.
3. **Single breakpoint** — Most layout decisions at 640px only; 800–1024 could improve tablet/desktop.
4. **No focus-visible** — No clear keyboard focus ring for links/buttons.
5. **Logo in dark mode** — SVG uses `#4f4f4f`; may not adapt to dark bg.
6. **Hashnode component** — Present in `_components.scss` but unused in layouts.

---

## 2. UI Improvement Plan

### 2.1 Priority: High (UX & accessibility)

| # | Improvement | Rationale | Approach |
|---|-------------|------------|----------|
| 1 | **Link contrast (light mode)** | WCAG and readability. | Increase light-mode link colour contrast (e.g. darker gray or blue tint) and ensure 4.5:1+ for body links; keep underline. |
| 2 | **Focus indicators** | Keyboard/screen reader users. | Add `:focus-visible` styles (outline/ring) for links, buttons, theme toggle; preserve no-outline for mouse `:focus`. |
| 3 | **Theme-aware logo** | Logo readability in dark mode. | Use CSS `currentColor` for logo SVG or add a dark-theme variant / filter so it inverts or lightens on dark bg. |

### 2.2 Priority: Medium (Clarity & consistency)

| # | Improvement | Rationale | Approach |
|---|-------------|------------|----------|
| 4 | **Reduce nav duplication** | Cleaner IA; one clear primary nav. | Keep header as primary (About, Blog, theme). In hero, remove duplicate “About Me” and “Blog”; keep one CTA (e.g. “See all posts” or “About me”) or a single primary action. |
| 5 | **Pagination affordance** | Clearer that “Previous/Next” are clickable. | Style disabled state (e.g. greyed, no pointer) and give active links stronger hover state. |
| 6 | **Post list hierarchy** | Scanability on blog/home. | Slightly increase title size or weight; add subtle spacing or divider between cards; consider optional “New” or “Updated” badge for recent posts. |

### 2.3 Priority: Lower (Polish & future-proofing)

| # | Improvement | Rationale | Approach |
|---|-------------|------------|----------|
| 7 | **Second breakpoint (e.g. 800px)** | Better use of tablet/small desktop. | At 800px: slightly larger hero text or spacing; optional sidebar width tweak; footer layout refinement. |
| 8 | **Touch targets** | Mobile usability. | Ensure nav links and theme toggle have min ~44px height/width (padding/line-height); add a bit more spacing on mobile. |
| 9 | **Unused Hashnode styles** | Cleaner codebase. | Remove or isolate `.hashnode-integration` in `_components.scss` unless planning to use it; or add a single “Featured”/external posts section that uses it. |
| 10 | **Micro-interactions** | Delight and feedback. | Short transition on theme toggle icon swap; optional subtle hover scale or underline animation on post titles. |

---

## 3. Suggested Implementation Order

1. **Phase 1 (quick wins)**  
   - Focus-visible styles.  
   - Light-mode link colour for contrast.  
   - Theme-aware logo (currentColor or dark variant).

2. **Phase 2 (IA & components)**  
   - Simplify hero CTAs (remove duplicate nav).  
   - Pagination disabled/active states.  
   - Post list hierarchy/spacing.

3. **Phase 3 (responsive & cleanup)**  
   - Optional 800px tweaks.  
   - Touch target sizing.  
   - Hashnode component decision (remove or use).

4. **Phase 4 (optional)**  
   - Micro-interactions (theme toggle, post title hover).

---

## 4. Files to Touch (reference)

| Change | Files |
|--------|--------|
| Link contrast | `_sass/_colors.scss` |
| Focus-visible | `_sass/_theme.scss` (and possibly `_typography.scss` for link focus) |
| Logo dark mode | `assets/logo.svg` and/or `_includes/site-logo.html` / `_theme.scss` |
| Hero CTAs | `_layouts/home.html`, `_sass/_theme.scss` (`.hero__nav`) |
| Pagination | `_sass/_theme.scss` (`.pagination`), `_includes/post-pagination.html` if markup changes |
| Post list / blog | `_sass/_theme.scss` (`.listing-title`, `.item--post`, etc.) |
| Breakpoints / touch | `_sass/_theme.scss`, `_sass/sassline-base/_variables.scss` |
| Hashnode | `_sass/_components.scss` |

---

## 5. Success Criteria (concise)

- **Accessibility:** Focus visible on all interactive elements; light-mode links pass WCAG AA.
- **Clarity:** One primary nav; no redundant hero links; pagination states obvious.
- **Consistency:** Logo readable in both themes; touch targets ≥44px where possible.
- **Maintainability:** Unused component styles removed or documented.

This plan can be executed in phases; start with Phase 1 for the highest impact with minimal risk.

---

## 6. Implemented (March 2026)

- **Phase 1:** `:focus-visible` (2px outline, link colour) site-wide; light-mode link colour set to `#1D4ED8` / hover `#1E40AF` for WCAG AA; dark-mode logo via `filter: brightness(0) invert(1)` on `.header .logo img`.
- **Phase 2:** Hero CTAs reduced to “About Me” and “LinkedIn” (Blog removed from hero); pagination styled (links vs disabled spans); post list spacing increased (1.5rem) and title hover transition added.
- **Phase 3:** `break-2` (800px) used for hero and recent-posts padding; nav links and theme toggle min-height 2.75rem (44px), hero CTA min-height and social icon touch targets; unused Hashnode block removed from `_components.scss`.
- **Phase 4:** Theme toggle `:active { transform: scale(0.97) }` and transition; listing and post title links use `transition: color 0.2s ease`.
