SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# === LOAD CONFIGURATION ===
include config.mk

ifeq ($(strip $(WWW_DIR)),)
$(error WWW_DIR must not be empty)
endif
ifeq ($(abspath $(WWW_DIR)),/)
$(error WWW_DIR must not be the filesystem root)
endif

.PHONY: all site site-check clean-site gather meta bib render copy-assets svg clean
.DELETE_ON_ERROR:
.SECONDARY: $(PRE_TEX)

# Suppress file deletion messages
.SILENT:

# Quiet mode: only show errors/warnings (no progress messages)
# Usage: make Q=1  or  make quiet
Q ?= 0
ifneq ($(Q),0)
  LOG = @true
  export QUIET_BUILD=1
else
  LOG = @echo
endif

# Default target.  With FILE=page.tex only that page is gathered and rendered,
# against the existing site metadata; the merge is skipped.
FILE ?=
ifeq ($(strip $(FILE)),)
all: gather meta render copy-assets
else
all: gather render copy-assets
endif

# Quiet build alias
.PHONY: quiet
quiet:
	$(MAKE) all Q=1

# Build the root landing pages and every currently published project. Future
# project directories join the public build only when added here.
PUBLISHED_PROJECTS := colored-matroids

.PHONY: root-site project-sites index-aliases
site: index-aliases

root-site: clean-site
	$(MAKE) all PROJECT=root SRC_DIR=. SITE_PATH= \
	  TEMP_DIR=$(BUILD_ROOT)/temp/root WWW_DIR=$(BUILD_ROOT)/www \
	  ENABLE_RELATION_GRAPH=0 Q=$(Q)

project-sites: root-site
	@for project in $(PUBLISHED_PROJECTS); do \
	  $(MAKE) all PROJECT="$$project" SRC_DIR="$$project" SITE_PATH="$$project" \
	    TEMP_DIR="$(BUILD_ROOT)/temp/$$project" WWW_DIR="$(BUILD_ROOT)/www/$$project" \
	    ENABLE_RELATION_GRAPH=0 Q=$(Q); \
	done

# GitHub Pages and most static servers use index.html for directory requests;
# the source toolchain continues to emit SymCat-compatible .htm pages.
index-aliases: project-sites
	@cp $(BUILD_ROOT)/www/index.htm $(BUILD_ROOT)/www/index.html
	@for project in $(PUBLISHED_PROJECTS); do \
	  cp "$(BUILD_ROOT)/www/$$project/index.htm" \
	     "$(BUILD_ROOT)/www/$$project/index.html"; \
	done
	@find "$(BUILD_ROOT)/www" -name .created -type f -delete

# Compatibility alias for the deployment bridge. The repository deliberately
# has no separate test suite; a complete site build is the check.
site-check: site

clean-site:
	@case "$(BUILD_ROOT)" in ""|"/") echo "[ERROR] Unsafe BUILD_ROOT='$(BUILD_ROOT)'" >&2; exit 2;; esac
	@rm -rf -- "$(BUILD_ROOT)"

# === CREATE BUILD DIRECTORIES ===
# Use stamp files to ensure directories are created exactly once
$(TEMP_DIR)/.created:
	@mkdir -p $(TEMP_DIR)
	@touch $@

$(WWW_DIR)/.created:
	@mkdir -p $(WWW_DIR)
	@touch $@

# === BIBLIOGRAPHY (must complete before gathering) ===
.PHONY: bib
bib: $(REFS_JSON) $(BIBTEX_JSON)

$(REFS_JSON): $(BIBFILE) $(BIB_MATH_FILTER) | $(TEMP_DIR)/.created
	$(LOG) "Generating $@"
	@# Only arXiv identifiers (2101.00001v2, math/0606360) become arXiv URLs.
	@sed -E 's/[Ee][Pp][Rr][Ii][Nn][Tt][[:space:]]*=[[:space:]]*\{([Aa][Rr][Xx][Ii][Vv]:)?([0-9]{4}\.[0-9]{4,5}(v[0-9]+)?|[a-z-]+(\.[A-Z]{2})?\/[0-9]{7}(v[0-9]+)?)\}/url = {https:\/\/arxiv.org\/abs\/\2}/g' $(BIBFILE) > $(TEMP_DIR)/bibfile_processed.bib
	@$(PANDOC) -f biblatex -t csljson $(TEMP_DIR)/bibfile_processed.bib \
	  --lua-filter=$(BIB_MATH_FILTER) --fail-if-warnings -o $@.tmp && mv $@.tmp $@

$(BIBTEX_JSON): $(BIBFILE) $(BIBTEX_EXTRACT_LUA) $(FILE_READING_LUA) $(UTILS_LUA) | $(TEMP_DIR)/.created
	$(LOG) "Generating $@"
	@$(LUA) $(BIBTEX_EXTRACT_LUA) $(BIBFILE) > "$@.tmp" && mv "$@.tmp" "$@"


# === 1) PREPROCESS: tex → pre.tex ===
# Order-only dependency on directory ensures it exists without triggering rebuilds
$(TEMP_DIR)/%.pre.tex: $(SRC_DIR)/%.tex $(PREPROC_DEPS) | $(TEMP_DIR)/.created
	$(LOG) "Preprocessing $< → $@"
	@$(LUA) $(PREPROC_LUA) "$<" < "$<" > "$@"

# === 2) GATHER: Collect metadata to JSON ===
.PHONY: gather
ifeq ($(strip $(FILE)),)
gather: $(JSON_FILES)
	$(LOG) "Gathered ALL → $(TEMP_DIR)/*.json"
else
gather: $(TEMP_DIR)/$(basename $(FILE)).json
	$(LOG) "Gathered $(FILE) → $(TEMP_DIR)/$(basename $(FILE)).json"
endif

# Here we use jq to format the json nicer
$(TEMP_DIR)/%.json: $(TEMP_DIR)/%.pre.tex $(GATHER_DEPS) $(REFS_JSON)
	$(LOG) "Gathering $< → $@"
	@$(PANDOC) "$<" --from=$(READER) --to=json --lua-filter=$(GATHER_LUA) --fail-if-warnings | jq '.' > "$@"

# === METADATA: Generate site-wide metadata ===
.PHONY: meta

# All site metadata outputs are produced by one merge pass, which rewrites an
# output only when its bytes change.  The stamp records that the merge ran, so
# an edit that leaves the metadata unchanged neither reruns the merge on every
# build nor triggers renders that depend on the outputs.  (A dry run, make -n,
# cannot see that the outputs kept their timestamps and lists every render.)
META_OUTPUTS := $(LABELS_JSON) $(POLYDATA_JSON) $(TODOS_JSON) $(SITEMAP_XML) $(GOTO_HTML) $(PUBLIC_LABELS_JSON) $(PUBLIC_KEYWORDS_JSON) $(PUBLIC_BIB_JSON)
ifneq ($(ENABLE_RELATION_GRAPH),0)
META_OUTPUTS += $(RELATION_GRAPH_HTML) $(RELATION_GRAPH_JSON)
endif
meta: $(META_OUTPUTS)

# A missing output forces a new merge.
ifneq ($(words $(wildcard $(META_OUTPUTS))),$(words $(META_OUTPUTS)))
$(shell rm -f $(META_STAMP))
endif

$(META_STAMP): $(JSON_FILES) $(TIMESTAMP_FILES) $(MERGE_META_DEPS) $(REFS_JSON) $(BIBTEX_JSON) $(TEMPLATE) | $(TEMP_DIR)/.created $(WWW_DIR)/.created
	$(LOG) "Generating site metadata ..."
	@$(LUA) $(MERGE_META_LUA) $(JSON_FILES)
	@touch "$@"

$(META_OUTPUTS): $(META_STAMP) ;

# === RENDER: Generate HTML ===
.PHONY: render
ifeq ($(strip $(FILE)),)
# Full build: pages depend on the site metadata
render: $(HTML_FILES)
	$(LOG) "Rendered ALL → $(WWW_DIR)/*.htm"
PAGE_META_PREREQS := $(LABELS_JSON) $(POLYDATA_JSON)
else
# Single file build: read the existing site metadata (from an earlier full
# build) without regenerating it
render: $(WWW_DIR)/$(basename $(FILE)).htm
	$(LOG) "Rendered $(SRC_DIR)/$(basename $(FILE)).tex → $(WWW_DIR)/$(basename $(FILE)).htm"
PAGE_META_PREREQS :=
endif

# Cache source timestamps
$(TEMP_DIR)/%.timestamp: $(SRC_DIR)/%.tex | $(TEMP_DIR)/.created
	@stat -c '%Y' "$<" > "$@"

$(WWW_DIR)/%.htm: $(TEMP_DIR)/%.json $(TEMP_DIR)/%.timestamp $(RENDER_DEPS) $(TEMPLATE) $(REFS_JSON) $(BIBTEX_JSON) $(PAGE_META_PREREQS) | $(WWW_DIR)/.created
	$(LOG) "Rendering $< → $@"
	@SOURCE_TS=$$(cat $(TEMP_DIR)/$*.timestamp) \
	$(LUA) $(RENDER_LUA) "$<" > "$@"

# === COPY ASSETS ===
.PHONY: copy-assets
copy-assets: $(COPY_ASSETS_STAMP)

$(COPY_ASSETS_STAMP): $(ASSET_FILES) $(WWW_DIR)/.created | $(TEMP_DIR)/.created
	$(LOG) "Copying assets..."
	@cp -r $(ASSETS_DIR)/* $(WWW_DIR)/
	@touch "$@"

# === SVG ASSETS ===
.PHONY: svg
# make svg FORCE=1 regenerates every figure regardless of timestamps.
svg:
	$(LOG) "Generating SVG assets..."
	@$(LUA) $(TEX_TO_SVG_LUA) $(if $(filter-out 0,$(FORCE)),--force)
	$(MAKE) copy-assets Q=$(Q)

# === CLEAN ===
.PHONY: clean
clean:
	@rm -rf $(TEMP_DIR) $(WWW_DIR)
