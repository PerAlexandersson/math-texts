# Math texts

This repository contains the sources for mathematical notes and course texts
intended for `math.qxy.se`.

The site is intended as a collection of independently organized projects
sharing one publishing system, visual language, and bibliography
infrastructure. Each project occupies one top-level directory and one
top-level URL. The initial projects are:

- `/colored-matroids/` for the evolving theory of colored matroids and its
  Lean formalization;
- `/symfun/` for notes from a course in symmetric functions;
- `/mm2001dm/` for discrete mathematics lecture notes.

## Source layout

Each published project is a top-level directory. Its `index.tex` links to the
project's chapter files. The repository root contains the site-wide landing
page, Make configuration, and HTML template. Shared Lua build tooling lives in
`scripts/`, while browser CSS, JavaScript, icons, and images live in `assets/`.
The build reads the shared `bibliography.bib` from a sibling checkout of
`symmetricfunctions.com`.

The initial colored-matroid outline is:

```text
colored-matroids/
├── index.tex
├── intro.tex
├── polytope.tex
└── rank.tex
```

`symfun/` and `mm2001dm/` remain tracked placeholders until their source texts
are added.

## Building

The build requires Lua 5.4, Pandoc, and `jq`:

```sh
make site
python3 -m http.server 8000 --directory /tmp/math-texts-build/www
```

By default, `SYMCAT_DIR=../symmetricfunctions.com`. Override `SYMCAT_DIR` (or
`BIBFILE` directly) if that checkout lives elsewhere. GitHub Actions checks out
both repositories side by side before building.

To build only the colored-matroid project, run `make`. Override `BUILD_ROOT`
when a different external output directory is needed. The complete site is
written to `$BUILD_ROOT/www`.

The rendering pipeline is adapted from
[`symmetricfunctions.com`](https://github.com/PerAlexandersson/symmetricfunctions.com).

GitHub Actions builds the site and uploads a review artifact.
