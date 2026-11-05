# Math texts agent guide

This is a public repository for the texts served from `math.qxy.se`.

- Keep content projects flat: one top-level directory per project, with an
  `index.tex` and sibling chapter files.
- Keep shared Lua build tooling in `scripts/` and browser assets in `assets/`;
  keep the Make configuration and HTML template at the repository root. Add a
  project to `PUBLISHED_PROJECTS` only when it has a buildable `index.tex`.
- Treat all tracked content and history as public. Never copy raw research
  evidence, private correspondence, credentials, or unpublished working-tree
  material here.
- The Lua pipeline is adapted from the pinned SymCat revision recorded in the
  README. Preserve its validation behavior when porting upstream changes.
- Every page needs `\metatitle`, `\metadescription`, and explicit labels on
  sections. Open, written, reviewed, and Lean-checked claims must remain
  distinct.
- Generated output belongs outside the repository. The default `BUILD_ROOT`
  is under `/tmp`; dependency trees and preview artifacts must not be committed.
- Never create symbolic links in this checkout.
- Run `make site`, `git diff --check`, and a symlink scan before a
  checkpoint. Do not configure or perform deployment without explicit user
  authorization.
