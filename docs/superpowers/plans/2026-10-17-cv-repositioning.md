# CV Repositioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reposition kkostenkov.github.io as the CV of a "Product-minded Tech Lead, Mobile Games", backed only by facts the owner confirmed, and make the site machine-readable.

**Architecture:** Keep the Jekyll remote theme (`sproogen/resume-theme`). All CV content lives in `_config.yml` and is rendered by the theme's includes. A local `_includes/person-jsonld.html` (included from `_layouts/defaultOverridden.html`) adds `Person` structured data. `llms.txt` is a static plain-text CV. A shell script `scripts/check-site.sh` builds the site and asserts required and forbidden strings; it plays the role of the test suite.

**Tech Stack:** Jekyll 3.9.3 (github-pages gem), Liquid, kramdown Markdown, bash, grep.

## Global Constraints

- Spec: `docs/superpowers/specs/2026-10-17-cv-repositioning-design.md`. Facts come only from it.
- Site title: `Product-minded Tech Lead, Mobile Games`.
- Tagline: `Unity lead who builds from the metrics: retention, monetization, A/B tests.`
- Experience claim: `13+ years of Unity and C#`, `10+ professionally`.
- Voodoo job title stays `Technical director`.
- All metrics belong to Archery Clash! (Voodoo). Coffee Pack has no metrics. Homa and Tripledot get no product or growth claims.
- Metric values exactly: Android low-end device tier (T4-T5) D1 retention `+5pp`; D1-D7 playtime `~+10%` with no revenue drop; store conversion `+2pp` (statistically significant); T3 revenue `+30%` after `-50%` prices.
- Never include: age, "without technical debt", growth-team SDK work at Homa, WebGL as a failed project, the unreleased web game, job-loss context.
- Archery Clash! pitch: `Archery game with a cast of female archers`.
- Use `Luna` for the playable-ad platform until the owner confirms `Playsomething`.
- No commit, push or deploy without the owner's go-ahead. Commit steps below are proposals; ask once before the first commit.
- Builds must never write into the repo: use the scratchpad path below as the destination.
- Wording gate: the owner reviews the copy in Tasks 2 to 5 before they are applied.

Scratchpad build dir used everywhere below:
`/private/tmp/claude-501/-Users-keeps-Documents-Repos-kkostenkov-github-io/bdd36d14-e4e8-4b37-8c1f-6cc88940f44c/scratchpad/site`

## File Structure

- Modify `_config.yml`: site title, description, url, exclude, about, all content sections, new portfolio entries.
- Modify `_layouts/defaultOverridden.html`: include the Person JSON-LD.
- Create `_includes/person-jsonld.html`: Person structured data.
- Create `llms.txt`: plain-text CV.
- Create `scripts/check-site.sh`: build and assert.
- Modify nothing else. Images and videos for new portfolio entries are out of scope (none supplied).

---

### Task 1: Check script and publish exclusions (the "failing test")

**Files:**
- Create: `scripts/check-site.sh`
- Modify: `_config.yml` (add `url`, `description`, `exclude` near the top, after `favicon:`)

**Interfaces:**
- Produces: `bash scripts/check-site.sh` exits 0 only if all required strings are present and forbidden ones absent. Later tasks make more assertions pass.

- [ ] **Step 1: Write the check script**

Create `scripts/check-site.sh`:

```bash
#!/usr/bin/env bash
# Builds the site into a scratch dir and checks required/forbidden content.
set -u
cd "$(dirname "$0")/.."
OUT="${SITE_OUT:-/private/tmp/claude-501/-Users-keeps-Documents-Repos-kkostenkov-github-io/bdd36d14-e4e8-4b37-8c1f-6cc88940f44c/scratchpad/site}"
bundle exec jekyll build -d "$OUT" >/dev/null 2>&1 || { echo "BUILD FAILED"; exit 2; }

fail=0
need() { # file, string
  grep -qF -- "$2" "$OUT/$1" || { echo "MISSING in $1: $2"; fail=1; }
}
forbid() { # file, string
  if grep -qF -- "$2" "$OUT/$1"; then echo "FORBIDDEN in $1: $2"; fail=1; fi
}

# Home page
need index.html "Product-minded Tech Lead, Mobile Games"
need index.html "Unity lead who builds from the metrics"
need index.html "13+ years"
need index.html "AI-assisted development"
need index.html "Impact at Voodoo"
need index.html "+5pp"
need index.html "+2pp"
need index.html "+30%"
need index.html "Technical director"
need index.html "Reel Heroes"
need index.html "Kitty Run"
need index.html 'application/ld+json'
need index.html '"@type": "Person"'
forbid index.html "Lead Unity Software Engineer"
forbid index.html "Great things in business"
forbid index.html "Active listening"
forbid index.html "Scaling up as a manager"
forbid index.html "Development Teamlead as a choice"
forbid index.html "technical debt"

# Order: AI section must come right after About, before Impact and Experience
ai=$(grep -n "AI-assisted development" "$OUT/index.html" | head -1 | cut -d: -f1)
imp=$(grep -n "Impact at Voodoo" "$OUT/index.html" | head -1 | cut -d: -f1)
exp=$(grep -n "<h3>Experience" "$OUT/index.html" | head -1 | cut -d: -f1)
if [ -z "$ai" ] || [ -z "$imp" ] || [ -z "$exp" ] || [ "$ai" -ge "$imp" ] || [ "$imp" -ge "$exp" ]; then
  echo "ORDER WRONG: AI($ai) < Impact($imp) < Experience($exp) expected"; fail=1
fi

# Portfolio
need portfolio.html "Archery Clash!"
need portfolio.html "Archery game with a cast of female archers"
need portfolio.html "Reel Heroes"
need portfolio.html "Kitty Run"
need portfolio.html "Coffee Pack"

# AI-readable layer
[ -f "$OUT/llms.txt" ] || { echo "MISSING llms.txt"; fail=1; }
need llms.txt "Product-minded Tech Lead"
need llms.txt "+5pp"
[ -d "$OUT/docs" ] && { echo "docs/ is being published"; fail=1; }
[ -d "$OUT/scripts" ] && { echo "scripts/ is being published"; fail=1; }

[ "$fail" -eq 0 ] && echo "ALL CHECKS PASSED" || echo "CHECKS FAILED"
exit "$fail"
```

- [ ] **Step 2: Run it and verify it fails**

Run: `bash scripts/check-site.sh`
Expected: many `MISSING ...` and `FORBIDDEN in index.html: Lead Unity Software Engineer` lines, then `CHECKS FAILED`, exit 1. (`BUILD FAILED` means fix the environment first: `bundle install`.)

- [ ] **Step 3: Add site metadata and exclusions to `_config.yml`**

Directly after the line `favicon: images/favicon.ico` add:

```yaml
url: https://kkostenkov.github.io
description: Kirill Kostenkov, Product-minded Tech Lead in mobile games. Unity, C#, A/B testing, monetization, AI-assisted development.
exclude:
  - docs
  - scripts
  - Gemfile
  - Gemfile.lock
  - node_modules
  - vendor
```

- [ ] **Step 4: Verify exclusions work**

Run: `bash scripts/check-site.sh 2>&1 | grep -E "docs/|scripts/"`
Expected: no output (neither directory is published).

- [ ] **Step 5: Commit (ask owner first)**

```bash
git add scripts/check-site.sh _config.yml docs
git commit -m "Add site check script and publish exclusions"
```

---

### Task 2: Title, about, AI section, Voodoo impact block

**Files:**
- Modify: `_config.yml` (`title:`, `about_content:` block, first two entries of `content:`)

**Interfaces:**
- Consumes: Task 1 check script.
- Produces: two new top-level `content:` sections titled `AI-assisted development` and `Impact at Voodoo (Archery Clash!)`, placed before `Experience`.

- [ ] **Step 1: Change the title**

Replace the line `title: Lead Unity Software Engineer` with:

```yaml
title: Product-minded Tech Lead, Mobile Games
```

- [ ] **Step 2: Replace the about text**

Replace the paragraph block inside `about_content: |` that starts with `Hi, my name's Kirill` and ends with the line `English - C1; French - B1; Spanish - B2; Russian - Native` by the following. Keep the two `<img ...>` lines above it unchanged and keep the 2-space indent used there:

```yaml
  **Unity lead who builds from the metrics: retention, monetization, A/B tests.**

  I'm Kirill, a tech lead in mobile games with 13+ years of Unity and C# (10+ professionally). I treat a studio as a business: the job is to ship products that earn, so I decide from retention, monetization and experiment results. I lead cross-functional teams of engineers, artists, designers, analysts and QA, and I use AI agents in daily production work. Based in Barcelona, Spain.

  My tech expertise lies in <mark>Unity</mark> and <mark>C#</mark>

  Language proficiency:
  English - C1; French - B1; Spanish - B2; Russian - Native
```

- [ ] **Step 3: Insert the two new sections**

Immediately after the line `content:` that opens the list of sections (the first `content:` at column 0, before `  - title: Experience`), insert:

```yaml
  - title: AI-assisted development
    layout: text
    content: |
      - **Daily hands-on use** of Claude Code (Copilot earlier) with MCP servers and custom skills in production work.
      - **Skills I wrote myself:** a customer-support answer database with automation, and an A/B-test conclusion skill that removes old assets, sets default values and strips code branching.
      - **Team adoption:** I pushed the team toward agent-assisted development and gave in-studio talks teaching non-technical colleagues the basics, token-saving tips and how to get reliable results when building prototypes.

  - title: Impact at Voodoo (Archery Clash!)
    layout: text
    content: |
      - **+5pp D1 retention** on low-end Android device tiers (T4-T5): built a system that adapts quality settings to device performance.
      - **~+10% D1-D7 playtime with no revenue drop:** A/B-tested the grace time before ads appear.
      - **+2pp store conversion**, statistically significant: ran a store listing experiment with updated screenshots and added keywords to title and description.
      - **+30% revenue in T3 countries:** tested a 50% price reduction.

```

- [ ] **Step 4: Run the check**

Run: `bash scripts/check-site.sh`
Expected: the `Product-minded`, `Unity lead who builds`, `13+ years`, `AI-assisted development`, `Impact at Voodoo`, `+5pp`, `+2pp`, `+30%` and the order check no longer appear as MISSING/ORDER WRONG. Still failing: Technical director, Reel Heroes, Kitty Run, JSON-LD, portfolio, llms.

- [ ] **Step 5: Commit (ask owner first)**

```bash
git add _config.yml
git commit -m "Reposition title and about, add AI and Voodoo impact sections"
```

---

### Task 3: Rewrite Experience

**Files:**
- Modify: `_config.yml` (the whole `  - title: Experience` section, up to but not including `  - title: Education`)

**Interfaces:**
- Consumes: section order from Task 2.

- [ ] **Step 1: Replace the Experience section**

Replace everything from `  - title: Experience` down to the line before `  - title: Education` with:

```yaml
  - title: Experience
    layout: list
    content:
      - layout: left
        title: Voodoo
        link: voodoo.io
        sub_title: Technical director
        caption: December 2024 - Present (Spain)
        description: |
            - Lead product teams on Coffee Pack and Archery Clash!. The team grew from 3 engineers and 2 QA into a cross-functional team of 5: engineer, data analyst, game designer, artist, QA.
            - Work with data analysts to design, run and read A/B tests, and decide the roadmap from the results (see impact above).
            - Define analytics events and funnels and use the data to prioritize work.
            - Run store listing optimization: keywords and listing experiments.
            - Built playable ads in Unity (Luna) from production project content for user acquisition.
            - Turned a prototype into a full product with a solid architecture and maintainable codebase; refine business requirements into technical tasks and keep a regular release pace.

      - layout: left
        title: HOMA games
        link: homagames.com
        sub_title: Lead Unity developer
        caption: March 2024 - December 2024 (Spain)
        description: |
            - Led a team of 4 engineers.
            - Re-established a relationship of mutual trust within the team.
            - Introduced core engineering principles step by step.

      - layout: left
        title: Tripledot Studios
        link: tripledotstudios.com
        sub_title: Lead Unity software engineer / Associate technical director
        caption: April 2022 - January 2024 (Spain)
        description: |
            - Managed 10 engineers during the company's rapid growth, introducing scalable processes and keeping software standards high.
            - Helped turn a group of individual contributors into one team.
            - Ran technical workshops for the studio and set up exchange of technology and experience between project teams.
            - Set up build tooling.

      - layout: left
        title: Helio
        link: heliogames.com
        sub_title: Lead developer
        caption: December 2019 - March 2022 (Russia)
        description: |
            Team lead: code reviews, interviews, hiring programmers and technical artists, development and technical roadmaps, deadlines.

      - layout: left
        title: Nival
        link: nival.com
        sub_title: Senior Unity developer
        caption: January 2017 - November 2019 (Russia)
        description: |
            Grew from middle to senior C# developer. Supported several live titles and contributed to prototypes that were not released.

      - layout: left
        title: iLocked
        link: ilocked.ru
        sub_title: Unity developer (VR)
        caption: May 2016 - November 2016 (Russia)
        description: |
            Solo developer of a multiplayer VR quest (Oculus Rift, HTC Vive, Perception Neuron).

      - layout: left
        title: Independent
        sub_title: Solo Unity developer
        caption: 2013 - 2016
        description: |
            First projects in Unity and C#, including the multiplayer tower defense Krownguards (see portfolio).

```

- [ ] **Step 2: Run the check**

Run: `bash scripts/check-site.sh`
Expected: no `MISSING ... Technical director`, no FORBIDDEN lines for the removed quotes ("Great things in business", "Active listening", "Scaling up as a manager", "Development Teamlead as a choice").

- [ ] **Step 3: Commit (ask owner first)**

```bash
git add _config.yml
git commit -m "Rewrite experience around confirmed facts"
```

---

### Task 4: Education, skills, personal projects

**Files:**
- Modify: `_config.yml` (sections `Education`, `Skills`, `Projects`)

- [ ] **Step 1: Replace the Education entry body**

Inside `  - title: Education`, replace the `quote:` and `description:` of the single entry (keep `title`, `caption`, `sub_title`) with:

```yaml
        description: |
          Studied people and team management, which I apply when leading engineering teams.
```

(Delete the `quote:` key and its two lines.)

- [ ] **Step 2: Replace the Skills text**

Replace the body of `  - title: Skills` (the `content: |` lines) with:

```yaml
    content: |
      13+ years of Unity and C#; .Net Core, ASP.NET Core  
      7+ years of leadership: Scrum, Git, Jira, team management, mentoring, expectations management  
      Product: A/B testing, retention and monetization analysis, store listing optimization (ASO), playable ads, PostHog  
      AI-assisted development: Claude Code, MCP servers, custom skills  
```

- [ ] **Step 3: Replace the Projects section**

Replace the whole `  - title: Projects` section with:

```yaml
  - title: Personal projects
    layout: text
    content: |
      - **[Reel Heroes](https://play.google.com/store/apps/details?id=com.PulpoFeliz.spin.spire.saga.heroes.dice.free.game)** (Google Play, solo): turn-based pixel roguelike RPG. Unity, VContainer, Addressables, UniRx, MessagePipe, PostHog.
      - **[Kitty Run](https://t.me/kk_endless_run_bot/)** (Telegram Mini App, solo): a game template adapted to Telegram, about 1k monthly users. Playgama Bridge SDK, AdsGram, Telegram Stars, PostHog.

      [More projects in the portfolio](portfolio)
```

- [ ] **Step 4: Run the check**

Run: `bash scripts/check-site.sh`
Expected: `Reel Heroes` and `Kitty Run` no longer missing in index.html.

- [ ] **Step 5: Commit (ask owner first)**

```bash
git add _config.yml
git commit -m "Update education, skills, add personal projects"
```

---

### Task 5: Portfolio entries

**Files:**
- Modify: `_config.yml` (insert three entries at the top of the `Portfolio` section's `content:`, before the `Coffee Pack` entry)

Coffee Pack stays unchanged: the owner said Archery Clash!'s role is "same as Coffee Pack plus product and project responsibilities", so Coffee Pack already carries its responsibilities. (This corrects the spec line that said to update Coffee Pack.)

- [ ] **Step 1: Insert the new entries**

Insert, with the same 6-space indent as sibling entries, directly before the line `      - layout: top-middle` that precedes `        title: "Coffee Pack"`:

```yaml
      - layout: top-middle
        title: "Archery Clash!"
        additional_links:
          - title:  Google Play
            icon: fab fa-google-play
            url: https://play.google.com/store/apps/details?id=archery.clash.tournament&hl=en
          - title:  App Store
            icon: fab fa-app-store
            url: https://apps.apple.com/us/app/archery-clash/id6458097001
        description: |
          #### Project
          Archery game with a cast of female archers.

          #### My part
          - Composition of the team and leading developers, QA, technical artists
          - Product and project responsibilities: roadmap from experiment results, management of business expectations and deadlines
          - Architecture planning, SDK integration, C# programming
          - A/B tests with data analysts, store listing optimization, playable ads

          #### Results
          - +5pp D1 retention on low-end Android device tiers (adaptive quality settings)
          - ~+10% D1-D7 playtime with no revenue drop (ad grace time test)
          - +2pp store conversion (listing experiment)
          - +30% revenue in T3 countries (-50% prices)

          #### Tech & skills
          <mark>Unity</mark>, <mark>C#</mark>, <mark>A/B testing</mark>, <mark>Remote configuration</mark>, <mark>Analytics</mark>, <mark>ASO</mark>, <mark>Team-leading</mark>

      - layout: top-middle
        title: "Reel Heroes"
        additional_links:
          - title:  Google Play
            icon: fab fa-google-play
            url: https://play.google.com/store/apps/details?id=com.PulpoFeliz.spin.spire.saga.heroes.dice.free.game
        description: |
          #### Project
          Personal project, recently launched. Turn-based pixel RPG roguelike: spin hero reels, plan your party, beat dungeons.

          #### My part
          - Solo development, from design to release

          #### Tech & skills
          <mark>Unity</mark>, <mark>VContainer</mark>, <mark>Addressables</mark>, <mark>UniRx</mark>, <mark>MessagePipe</mark>, <mark>PostHog</mark>

      - layout: top-middle
        title: "Kitty Run"
        additional_links:
          - title:  Telegram
            icon: fab fa-telegram
            url: https://t.me/kk_endless_run_bot/
        description: |
          #### Project
          Personal project: a game template adapted to a Telegram Mini App. About 1k monthly users.

          #### My part
          - Solo adaptation, SDK integration, monetization and analytics setup

          #### Tech & skills
          <mark>Telegram Mini Apps</mark>, <mark>Playgama Bridge SDK</mark>, <mark>AdsGram</mark>, <mark>Telegram Stars</mark>, <mark>PostHog</mark>

```

- [ ] **Step 2: Run the check**

Run: `bash scripts/check-site.sh`
Expected: no `MISSING in portfolio.html` lines.

- [ ] **Step 3: Commit (ask owner first)**

```bash
git add _config.yml
git commit -m "Add Archery Clash, Reel Heroes, Kitty Run to portfolio"
```

---

### Task 6: AI-readable layer

**Files:**
- Create: `_includes/person-jsonld.html`
- Modify: `_layouts/defaultOverridden.html` (add one include line)
- Create: `llms.txt`

- [ ] **Step 1: Create the Person structured data**

Create `_includes/person-jsonld.html`:

```html
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Person",
  "name": "Kirill Kostenkov",
  "jobTitle": "Product-minded Tech Lead, Mobile Games",
  "description": "Unity lead who builds from the metrics: retention, monetization, A/B tests.",
  "url": "https://kkostenkov.github.io/",
  "email": "mailto:kkostenkov@gmail.com",
  "address": { "@type": "PostalAddress", "addressLocality": "Barcelona", "addressCountry": "ES" },
  "sameAs": [
    "https://github.com/kkostenkov",
    "https://www.linkedin.com/in/kkostenkov",
    "https://t.me/kiparis87"
  ],
  "worksFor": { "@type": "Organization", "name": "Voodoo", "url": "https://voodoo.io" },
  "alumniOf": [
    { "@type": "Organization", "name": "HOMA games" },
    { "@type": "Organization", "name": "Tripledot Studios" },
    { "@type": "Organization", "name": "Helio" },
    { "@type": "Organization", "name": "Nival" },
    { "@type": "CollegeOrUniversity", "name": "St. Petersburg State University of Engineering and Economics" }
  ],
  "knowsLanguage": ["English", "French", "Spanish", "Russian"],
  "knowsAbout": [
    "Unity", "C#", "Mobile game development", "Technical leadership",
    "A/B testing", "Retention and monetization", "App store optimization",
    "Playable ads", "AI-assisted development", "Claude Code", "MCP",
    "Telegram Mini Apps", ".NET Core", "ASP.NET Core"
  ]
}
</script>
```

- [ ] **Step 2: Include it from the home layout**

In `_layouts/defaultOverridden.html`, directly after the `<body class="...">` line, add:

```liquid
  {%- include person-jsonld.html -%}
```

- [ ] **Step 3: Create `llms.txt`**

Create `llms.txt` at the repo root (no front matter, copied as-is):

```text
# Kirill Kostenkov

> Product-minded Tech Lead, Mobile Games. Unity lead who builds from the metrics: retention, monetization, A/B tests. 13+ years of Unity and C# (10+ professionally). Based in Barcelona, Spain.

Site: https://kkostenkov.github.io/
Portfolio: https://kkostenkov.github.io/portfolio
LinkedIn: https://www.linkedin.com/in/kkostenkov
GitHub: https://github.com/kkostenkov
Contact: kkostenkov@gmail.com

## AI-assisted development
- Daily use of Claude Code (Copilot earlier) with MCP servers and custom skills.
- Wrote skills: customer-support answer database with automation; A/B-test conclusion skill that removes old assets, sets default values and strips code branching.
- Pushed the team to agent-assisted development; gave in-studio talks for non-technical colleagues.

## Impact at Voodoo (Archery Clash!)
- +5pp D1 retention on low-end Android device tiers (T4-T5) via adaptive quality settings.
- ~+10% D1-D7 playtime with no revenue drop (ad grace time A/B test).
- +2pp store conversion, statistically significant (listing experiment).
- +30% revenue in T3 countries (-50% prices).

## Experience
- Voodoo, Technical director, Dec 2024 - present. Team grew from 3 engineers + 2 QA to a cross-functional team of 5. A/B tests with analysts, analytics, ASO, playable ads (Luna).
- HOMA games, Lead Unity developer, Mar 2024 - Dec 2024. Led 4 engineers.
- Tripledot Studios, Lead Unity software engineer / Associate technical director, Apr 2022 - Jan 2024. Managed 10 engineers.
- Helio, Lead developer, Dec 2019 - Mar 2022.
- Nival, Senior Unity developer, Jan 2017 - Nov 2019.
- iLocked, Unity developer (VR), May 2016 - Nov 2016.
- Independent, solo Unity developer, 2013 - 2016.

## Personal projects
- Reel Heroes (Google Play, solo): turn-based pixel roguelike RPG.
- Kitty Run (Telegram Mini App, solo): game template adapted to Telegram, about 1k monthly users.

## Education
St. Petersburg State University of Engineering and Economics, Bachelor, Human Resources, 2005 - 2010.

## Languages
English C1, French B1, Spanish B2, Russian native.
```

- [ ] **Step 4: Run the check**

Run: `bash scripts/check-site.sh`
Expected: `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 5: Validate the JSON**

Run: `python3 -c "import re,json,sys; s=open('_includes/person-jsonld.html').read(); json.loads(re.search(r'<script[^>]*>(.*)</script>', s, re.S).group(1)); print('json ok')"`
Expected: `json ok`

- [ ] **Step 6: Commit (ask owner first)**

```bash
git add _includes/person-jsonld.html _layouts/defaultOverridden.html llms.txt
git commit -m "Add Person JSON-LD and llms.txt"
```

---

### Task 7: Visual and print verification

**Files:** none modified unless a defect is found.

- [ ] **Step 1: Serve locally**

Run (in the background): `bundle exec jekyll serve -d /private/tmp/claude-501/-Users-keeps-Documents-Repos-kkostenkov-github-io/bdd36d14-e4e8-4b37-8c1f-6cc88940f44c/scratchpad/serve`
Expected: `Server address: http://127.0.0.1:4000/`

- [ ] **Step 2: Screenshot both pages with the browser tools**

Load the Chrome tools (`/anthropic-skills:chrome-browser` guidance), open `http://127.0.0.1:4000/` and `http://127.0.0.1:4000/portfolio`, screenshot at desktop and at phone width. Check: header shows the new title; AI section directly follows About; Impact list reads cleanly; experience bullets render as lists; no raw Markdown or HTML visible; Archery Clash! store buttons appear; no horizontal scroll on mobile.

- [ ] **Step 3: Check print layout**

Emulate print (Cmd+P preview or `@media print` emulation). Check: sections do not split awkwardly, the `no-print` icons are hidden, length is about 2 pages. If a page break splits a section badly, reuse the page-break approach from commit `f32d199` ("Add few lines for pdf page break"): `git show f32d199`.

- [ ] **Step 4: Report to the owner**

Show the screenshots and list any defect. Fix defects in `_config.yml` and re-run `bash scripts/check-site.sh`. Stop the server.

- [ ] **Step 5: Final commit and wording sign-off (ask owner first)**

Get the owner's approval of the rendered wording, resolve the open items (final tagline, About text, Voodoo team-growth phrasing, `Luna` vs `Playsomething`, Barcelona, Independent 2013 start), then commit remaining changes.

---

## Self-Review

- **Spec coverage:** header/title/tagline (Task 2); about with 13+ years (Task 2); AI section after About (Task 2); Impact block (Task 2); experience incl. Homa 4, Tripledot 10 with small build-tooling line, shortened Helio/Nival/iLocked, indie line (Task 3); education, skills, personal projects (Task 4); portfolio additions (Task 5); JSON-LD and llms.txt (Task 6); docs excluded and metadata (Task 1); print and screenshots (Task 7). Coffee Pack: deliberately unchanged, noted in Task 5.
- **Placeholders:** none; all copy is final draft pending the owner's wording review.
- **Consistency:** section titles used in the check script (`AI-assisted development`, `Impact at Voodoo`) match the titles inserted in Task 2; metric strings `+5pp`, `+2pp`, `+30%` match across config, JSON text and llms.txt.
- **Known risk:** the check script's section-order test assumes the theme renders section titles as `<h3>`; if a failure says `ORDER WRONG` while the page looks right, inspect `$OUT/index.html` and adjust the `<h3>Experience` pattern.
