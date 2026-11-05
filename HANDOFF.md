# Current handoff

## Shared bibliography and leaner build — ready 2026-11-05

Ownership released. Removed the duplicate `bibliography.bib`, `tests/`, and
`config_test.mk`. The build reads SymCat's bibliography through configurable
`SYMCAT_DIR`/`BIBFILE`; CI checks out both repositories side by side. The full
site build is now the check, with `site-check` retained only as a deployment
bridge compatibility alias. Public documentation and the SVG helper no longer
contain machine-specific paths. `make site Q=1 LUA=lua5.4
BUILD_ROOT=/tmp/math-texts-shared-bib-check`, `git diff --check`, and the
repository symlink scan pass. User authorized deployment; this checkpoint has
not yet been deployed.

## Width-control deployment — complete 2026-11-05

The constrained qxy.se bridge deployed exact clean commit
`f61c137f4144772d6ac09596e6c3c637662fb3d4` under receipt
`20261105T093838-04d158e818e9`. This predates the shared-bibliography cleanup.

## Script layout and width-control first paint — ready 2026-11-05

Ownership released. All shared Lua executables/modules now live in `scripts/`;
Make dependencies, test helpers, the relation-graph source link, project guide,
and README use the new paths. The root retains the Make/configuration files and
`template.htm`.

Reading-page classification and `has-text-width` are now rendered into the
initial HTML. The width button is static template markup, non-reading pages hide
it from first paint, and the early head script applies a saved narrow preference
before CSS renders. `site.js` now binds behavior without injecting the control
or changing the desktop grid after `DOMContentLoaded`. Asset cache keys are at
version 2 so old JS cannot run against the new markup.

`make site-check Q=1 LUA=lua5.4 BUILD_ROOT=/tmp/math-texts-layout-check`,
`git diff --check`, and the repository symlink scan pass. Chrome screenshots at
1440x1100 verified the article and project-index layouts; a 390x844 article
check verified the mobile control order and content. Raw and post-JS article
HTML both contain `reading-document`, `has-text-width`, and the static control.
Deployment has not been requested or performed for this checkpoint.

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
