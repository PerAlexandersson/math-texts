# Math texts agent guide

This is a public repository for the texts served from `math.qxy.se`.

- Keep content projects flat: one top-level directory per project, with an
  `index.tex` and sibling chapter files.
- Keep shared build tooling and assets at the repository root. Add a project
  to `PUBLISHED_PROJECTS` only when it has a buildable `index.tex`.
- Treat all tracked content and history as public. Never copy raw research
  evidence, private correspondence, credentials, or unpublished working-tree
  material here.
- The Lua pipeline is adapted from the pinned SymCat revision recorded in the
  README. Preserve its validation behavior when porting upstream changes.
- Every page needs `\metatitle`, `\metadescription`, and explicit labels on
  sections. Open, written, reviewed, and Lean-checked claims must remain
  distinct.
- Generated output belongs outside Dropbox. The default `BUILD_ROOT` is under
  `/tmp`; dependency trees and preview artifacts must not be committed.
- Never create symbolic links anywhere in this Dropbox checkout.
- Run `make site-check`, `git diff --check`, and a symlink scan before a
  checkpoint. Do not configure or perform deployment without explicit user
  authorization.
