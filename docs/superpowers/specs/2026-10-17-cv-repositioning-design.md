# CV site repositioning: design

Date: 2026-10-17. Status: intent approved by user; wording not yet reviewed.

## Goal

Reposition kkostenkov.github.io so a recruiter sees a product-minded Unity tech lead whose claims are backed by facts. LinkedIn is updated by hand afterwards from the same facts.

## Decisions

- Keep the Jekyll theme (`sproogen/resume-theme`). No framework migration.
- No linking between portfolio entries and experience entries.
- Rewrite content and structure in `_config.yml`, plus add an AI-parsable layer.
- Every bullet is shown to the user for review before it is committed.
- Voodoo job title stays literal: "Technical director".
- Excluded from the site: age, "without technical debt", growth-team SDK work at Homa, WebGL as a failed project, the web game (unreleased), job-loss context, and CI/CD emphasis (one small line at Tripledot only).

## Facts (source: user, this conversation)

**Header**
- Title: "Product-minded Tech Lead, Mobile Games".
- Tagline: "Unity lead who builds from the metrics: retention, monetization, A/B tests."
- 13+ years of Unity and C#, 10+ professionally. Add an indie/solo line before 2016 (Krownguards).

**Voodoo (Dec 2024 to present). Product experience comes only from here. Project: Archery Clash!**
- Device-tier adaptive quality settings: Android low-end tier D1 retention +5pp.
- A/B test of ad grace time: D1 to D7 playtime about +10%, no revenue drop.
- Store listing experiment (updated screenshots from artists, keywords in title and description): conversion +2pp, statistically significant.
- Regional pricing experiment: prices -50% in T3 countries, T3 revenue +30%.
- Playable ads built in Unity (Luna). No variant count stated.
- Team grew from 3 engineers + 2 QA to a 5-person cross-functional team (engineer, data analyst, game designer, artist, QA).
- First Voodoo project: Coffee Pack. Second: Archery Clash!. All metrics belong to Archery Clash!. Coffee Pack has no metrics.

**AI-assisted development (own section, directly after About)**
- Daily use of Claude Code (earlier Copilot), MCP servers, and self-written skills: customer-support answer database and automation; an A/B conclusion skill that removes old assets, sets default values and strips code branching.
- Encouraged the team to adopt agent-assisted development. Gave in-studio talks teaching non-technical colleagues basics, token-saving tips and reliable prototyping.

**Other roles**
- Homa Games: 4 engineers. Engineering and leadership only.
- Tripledot Studios: 10 engineers. Engineering and leadership, small CI/CD mention.
- Helio, Nival, iLocked: shortened to one line each.

**Personal projects**
- Reel Heroes (Google Play, solo): turn-based pixel roguelike RPG. VContainer, Addressables, PostHog, UniRx, MessagePipe. No metrics claimed.
- Kitty Run (Telegram Mini App, solo): existing game template adapted to Telegram, about 1k monthly users. Playgama Bridge, AdsGram, Telegram Stars, PostHog.

**Archery Clash!**
- Pitch: "Archery game with a cast of female archers."
- Google Play: https://play.google.com/store/apps/details?id=archery.clash.tournament&hl=en
- App Store: https://apps.apple.com/us/app/archery-clash/id6458097001
- User's part: same as Coffee Pack plus product and project responsibilities.

## Page changes

**`/` (index)**
1. Header with new title and tagline.
2. About: about 4 sentences. 13+ years, business view of game dev, cross-functional leadership.
3. AI-assisted development section.
4. Impact at Voodoo block: the four metrics, each with what was done.
5. Experience: Voodoo full; Homa and Tripledot concise; Helio, Nival, iLocked one line; fluff quotes removed; indie line added.
6. Personal projects: two lines each with links.
7. Skills, education (HR angle without the "crucial advantage" spin), languages.

**`/portfolio`**
- Add Archery Clash!, Reel Heroes, Kitty Run.
- Update Coffee Pack with product and project responsibilities, no metrics.
- Existing older entries kept as they are.

## AI-parsable layer

- `Person` JSON-LD (job history, skills, knowsAbout) in the head. The current build already emits one JSON-LD block from `jekyll-seo-tag`, so this extends or replaces it.
- `/llms.txt`: plain-text version of the CV.
- Clean titles, descriptions and heading structure. Content stays real text in semantic HTML.

## Implementation notes and risks

- `docs/` must be added to `exclude:` in `_config.yml`, or Jekyll will publish these spec files as pages.
- Content is built by `bundle exec jekyll serve`; verify rendered HTML locally and screenshot `/` and `/portfolio` before declaring done.
- The page must still print cleanly to PDF (recent commits tuned page breaks).
- Open wording items for the review step: tagline final text, About text, the Voodoo team-growth phrasing, "Luna" vs "Playsomething", one-line summaries for Helio, Nival and iLocked.
