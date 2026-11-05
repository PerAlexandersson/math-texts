# Current handoff

## Minimal live deployment — complete 2026-11-05

The constrained qxy.se bridge built and deployed exact clean commit
`a83d5619d52748b1a1815e75429252881d009ccd` to `https://math.qxy.se/` under
receipt `20261105T092004-7af86f0b7a92`. The root, `/colored-matroids/`, and
`/colored-matroids/intro.htm` each returned HTTP 200 with expected titles.
This was an additive upload; no stale-file pruning or unrelated remote change
was performed. Source ownership is released.

## Initial build system and colored-matroid outline — ready

Ownership is released. The repository vendors the SymCat Lua/Pandoc toolchain
at `8681eba774d7204ce0981b6eb666495aba7c500e`, with project-aware canonical
URLs, source links, external build paths, and an optional relation graph. A
distinct `template.htm` brands the site as Math texts. The root landing/search
pages and `colored-matroids/{index,intro,polytope,rank,search}.tex` build into
`/tmp/math-texts-build/www` by default. `symfun/` and `mm2001dm/` remain empty
placeholders.

`make site-check Q=1` passes the inherited unit/backend/safeguard suite and
both root/project HTML audits. `git diff --check` passes and the repository
symlink scan is empty. Root, `/colored-matroids/`, and the introduction return
HTTP 200 in a local preview. Chrome screenshots at 1440x1100 and 390x844 were
inspected for the colored-matroid landing/article layouts. GitHub Actions
builds the same site and uploads a 14-day review artifact. No Pages setting,
DNS record, hosting identity, or deployment has been configured.
