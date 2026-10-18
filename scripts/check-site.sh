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
need index.html "Automated product health checks"
need index.html "Impact at Voodoo"
need index.html "+5pp"
need index.html "+5pp store conversion"
need index.html "+30%"
need index.html "Technical director"
forbid index.html "Reel Heroes"
forbid index.html "Kitty Run"
need index.html "9+ years of leadership"
need index.html 'application/ld+json'
need index.html '"@type": "Person"'
forbid index.html "Lead Unity Software Engineer"
forbid index.html "Great things in business"
forbid index.html "Active listening"
forbid index.html "Scaling up as a manager"
forbid index.html "Development Teamlead as a choice"
forbid index.html "technical debt"

# Order: AI section must come right after About, before Impact and Experience
ai=$(grep -n "<h3>AI-assisted development" "$OUT/index.html" | head -1 | cut -d: -f1)
imp=$(grep -n "<h3>Impact at Voodoo" "$OUT/index.html" | head -1 | cut -d: -f1)
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
