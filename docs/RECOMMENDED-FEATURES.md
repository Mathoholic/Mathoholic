# Recommended Features for Mathoholic (Research-Based)

**Sources:** Developer portfolio checklists, technical blog best practices, and recruiter/hiring guides (2024–2026).  
**Purpose:** Prioritised list of features this site could have, with “already have” vs “consider adding.”

---

## ✅ What You Already Have

| Feature | Notes |
|--------|--------|
| **Clear value proposition** | Homepage states role: “Data Scientist & Backend Engineer \| AI, LLMs, ETL & Scalable Systems” |
| **About / bio** | About page with skills, focus, philosophy, links |
| **Blog** | Technical posts, pagination, meta (date, read time, tags) |
| **RSS** | `jekyll-feed` — readers can subscribe |
| **SEO** | Meta description, canonical URL, Open Graph, Twitter Cards, article dates |
| **Sitemap** | `jekyll-sitemap` for search engines |
| **Responsive + performance** | Mobile-friendly layout, compressed Sass, readable typography |
| **Accessibility** | Focus-visible, semantic HTML, theme toggle (dark/light) |
| **Social links** | Footer: Facebook, Threads, LinkedIn, Instagram |
| **Contact entry points** | About page: LinkedIn, GitHub, RebuildHQ, Topmate, email |
| **Resume** | `resume/` with Markdown + HTML generation (not in main nav) |

---

## 1. Core Content & Structure (High Impact)

| Feature | Why it matters | Effort |
|--------|----------------|--------|
| **Projects showcase** | 3–5 projects with stack, role, impact, and live/Repo links are one of the top things recruiters look for. | Medium – new collection or section + layout |
| **Resume/CV in nav** | Single “Resume” or “CV” link (PDF or page) makes it easy for recruiters to download or view. | Low – link existing resume output in nav |
| **Contact page or section** | Dedicated contact (email + optional Calendly/Topmate) with a clear CTA (“Let’s talk”, “Book a call”) improves conversion. | Low – page or expanded About block |
| **Case studies** | For 1–2 best projects: problem, approach, challenges, results. Differentiates you from “just a list of repos.” | Medium – content + optional layout |

---

## 2. Blog & Content (High Impact)

| Feature | Why it matters | Effort |
|--------|----------------|--------|
| **Search** | Client-side (e.g. Lunr/Pagefind) or external (Algolia) so visitors can find posts by keyword. | Low–Medium |
| **Related posts** | “You might also like” at the end of each post increases time on site and discovery. | Low – Jekyll `site.posts` + tags/categories |
| **Table of contents (TOC)** | Long posts benefit from in-page TOC; good for SEO and UX. | Low – plugin or Kramdown TOC |
| **Reading progress** | Thin bar or indicator showing scroll progress in long articles. | Low – small JS + CSS |
| **Newsletter / RSS-to-email** | Lets subscribers get new posts by email (Buttondown, FeedToMail, etc.). | Low – link + optional embed |
| **Code syntax highlighting** | Already common in Jekyll; ensure it’s consistent and readable in both themes. | Low – verify Rouge/highlighter |

---

## 3. Trust & Conversion (Medium Impact)

| Feature | Why it matters | Effort |
|--------|----------------|--------|
| **Testimonials / endorsements** | Short quotes from colleagues or clients add social proof. | Low – static section or include |
| **Certifications / awards** | Badges or list of certs (e.g. AWS, Coursera) if relevant. | Low – section on About or dedicated block |
| **GitHub / contribution highlights** | Link to GitHub; optional “pinned repos” or contribution graph embed. | Low – link; Medium if you embed widget |
| **Clear CTA above the fold** | One primary action on home (e.g. “View my work”, “Read the blog”, “Get in touch”). | Low – copy/layout tweak |

---

## 4. Technical & Analytics (Medium Impact)

| Feature | Why it matters | Effort |
|--------|----------------|--------|
| **Analytics** | Understand traffic and which content/pages perform (e.g. Plausible, Fathom, GA4). | Low – add script + optional cookie banner |
| **Visitor / hit counter** | Optional “X visitors” or “X page views” for social proof (Counter.dev, Busuanzi, or analytics-based). | Low – script or build-time metric |
| **robots.txt / security headers** | You have `robots.txt`; on GitHub Pages, headers are limited but worth documenting. | Low – verify and document |
| **Performance monitoring** | Occasional Core Web Vitals check (PageSpeed Insights) to keep load time &lt; 3s. | Low – manual or CI check |

---

## 5. Nice-to-Have (Lower Priority)

| Feature | Why it matters | Effort |
|--------|----------------|--------|
| **Comments** | Optional for blog (e.g. Giscus, Utterances) if you want discussion. | Low – add to post layout |
| **Copy button on code blocks** | One-click copy for snippets improves UX. | Low – JS snippet |
| **Series / multi-part posts** | “Part 1”, “Part 2” links for tutorial series. | Low – front matter + include |
| **Print-friendly styles** | `@media print` for resume and articles. | Low – print CSS |
| **Language / locale** | Only if you target multiple languages; you already have `lang: en-GB`. | Medium |

---

## Suggested Order to Add (Next 3–6 Months)

1. ~~**Resume in nav**~~ — ✅ Done: `/resume` page with "View online" + "Download PDF"; added to nav.  
2. ~~**Contact page or CTA**~~ — ✅ Done — Dedicated contact page or prominent “Get in touch” on About with email + Topmate.  
3. ~~**Projects section**~~ — ✅ Done: `/projects` page with 4 projects from `_data/projects.yml`; added to nav.  
4. ~~**Related posts**~~ — ✅ Done: `_includes/related-posts.html` on post layout; matches by tags, fallback to recent.  
5. **Search** — Client-side search (e.g. Pagefind for Jekyll) so visitors can find posts quickly.  
6. **Analytics** — Lightweight analytics (e.g. Plausible or Fathom) to see traffic and popular posts.  
7. **Newsletter link** — Add “Subscribe by email” pointing to RSS-to-email (e.g. Buttondown) or feed.  
8. **Visitor count (optional)** — Only if you want a visible “X visitors” or “X page views” (e.g. Counter.dev or analytics-based).

---

## Summary Table

| Category | Already have | High priority to add | Later |
|----------|--------------|----------------------|--------|
| **Content** | About, Blog, RSS, Sitemap, Projects, Resume, Contact | — | Case studies |
| **Blog UX** | Pagination, meta, tags, related posts | Search, TOC | Comments, series |
| **Trust** | Social links, clear bio | CTA, optional testimonials | Certifications |
| **Technical** | SEO, a11y, responsive, dark mode | Analytics, optional visitor count | Print CSS, copy button |

This list is a living doc: you can tick items off as you implement them and adjust priorities as your goals change (e.g. job search vs. thought leadership vs. consulting).
