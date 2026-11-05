# Math texts

This repository contains the sources for mathematical notes and course texts
intended for `math.qxy.se`.

The site is intended as a collection of independently organized projects
sharing one publishing system, visual language, bibliography infrastructure,
and search interface. Each project occupies one top-level directory and one
top-level URL. The initial projects are:

- `/colored-matroids/` for the evolving theory of colored matroids and its
  Lean formalization;
- `/symfun/` for notes from a course in symmetric functions;
- `/mm2001dm/` for discrete mathematics lecture notes.

## Source layout

Each published project is a top-level directory. Its `index.tex` links to the
project's chapter files. The repository root contains the site-wide landing
page, bibliography, Make configuration, and HTML template. Shared Lua build
tooling lives in `scripts/`, while browser CSS, JavaScript, icons, and images
live in `assets/`.

The initial colored-matroid outline is:

```text
colored-matroids/
├── index.tex
├── intro.tex
├── polytope.tex
├── rank.tex
└── search.tex
```

`symfun/` and `mm2001dm/` remain tracked placeholders until their source texts
are added.

## Building

The build requires Lua 5.4, Pandoc, `jq`, and Node's `npx`. Generated files
stay outside the Dropbox checkout by default:

```sh
make site
make site-check
python3 -m http.server 8000 --directory /tmp/math-texts-build/www
```

To build only the colored-matroid project, run `make`. Override `BUILD_ROOT`
when a different external output directory is needed. The complete site is
written to `$BUILD_ROOT/www`.

The rendering pipeline is adapted from
[`symmetricfunctions.com`](https://github.com/PerAlexandersson/symmetricfunctions.com)
at revision `8681eba774d7204ce0981b6eb666495aba7c500e`. It retains the tested
preprocessor, Pandoc gatherer, Lua renderer, bibliography support, cross-page
references, Pagefind search, and HTML safeguards, with a separate template and
parameterized domain, project path, and source links.

GitHub Actions builds and checks the site and uploads a review artifact. It
does not deploy the site; publication to `math.qxy.se` uses the separately
registered constrained deployment bridge.
