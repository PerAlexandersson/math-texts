# === PROJECT BUILD CONFIGURATION ===

PROJECT ?= colored-matroids
BUILD_ROOT ?= /tmp/math-texts-build

ifeq ($(PROJECT),root)
SRC_DIR ?= .
SITE_PATH ?=
WWW_DIR ?= $(BUILD_ROOT)/www
else
SRC_DIR ?= $(PROJECT)
SITE_PATH ?= $(PROJECT)
WWW_DIR ?= $(BUILD_ROOT)/www/$(PROJECT)
endif

ASSETS_DIR ?= assets
SCRIPTS_DIR ?= scripts
TEMP_DIR ?= $(BUILD_ROOT)/temp/$(PROJECT)

TEMPLATE ?= $(PROJECT)/template.htm
SYMCAT_DIR ?= ../symmetricfunctions.com
BIBFILE ?= $(SYMCAT_DIR)/bibliography.bib

SITE_BASE_URL ?= https://math.qxy.se
SOURCE_REPOSITORY ?= https://github.com/PerAlexandersson/math-texts
SOURCE_BRANCH ?= main
ENABLE_RELATION_GRAPH ?= 0

# === TOOLS ===
PANDOC ?= pandoc
LUA ?= lua
# Sections must have explicit labels, so Pandoc's automatic ids are off.
READER ?= latex+raw_tex-auto_identifiers

# === SCRIPTS ===
PREPROC_LUA    = $(SCRIPTS_DIR)/preprocess.lua
GATHER_LUA     = $(SCRIPTS_DIR)/gather.lua
RENDER_LUA     = $(SCRIPTS_DIR)/render.lua
MERGE_META_LUA = $(SCRIPTS_DIR)/merge_meta.lua
RELATION_GRAPH_LUA = $(SCRIPTS_DIR)/relation_graph.lua
TEX_TO_SVG_LUA = $(SCRIPTS_DIR)/tex_to_svg.lua

# === LUA LIBRARY DEPENDENCIES ===
UTILS_LUA          = $(SCRIPTS_DIR)/utils.lua
FILE_READING_LUA   = $(SCRIPTS_DIR)/file_reading.lua
BIBHANDLER_LUA     = $(SCRIPTS_DIR)/bibhandler.lua
BIB_MATH_FILTER    = $(SCRIPTS_DIR)/bib_math_filter.lua
BIBTEX_EXTRACT_LUA = $(SCRIPTS_DIR)/bibtex_extract.lua
FIG_TO_HTML_LUA    = $(SCRIPTS_DIR)/figure_to_html.lua
POLY_TO_HTML_LUA   = $(SCRIPTS_DIR)/polydata_to_html.lua
RELATION_REGISTRY_LUA = $(SCRIPTS_DIR)/relation_registry.lua

PREPROC_DEPS    = $(PREPROC_LUA) $(UTILS_LUA)
GATHER_DEPS     = $(GATHER_LUA) $(UTILS_LUA) $(FILE_READING_LUA) $(BIBHANDLER_LUA) $(RELATION_REGISTRY_LUA) $(FIG_TO_HTML_LUA)
RENDER_DEPS     = $(RENDER_LUA) $(UTILS_LUA) $(BIBHANDLER_LUA) $(FILE_READING_LUA) $(FIG_TO_HTML_LUA) $(POLY_TO_HTML_LUA) $(RELATION_REGISTRY_LUA)
MERGE_META_DEPS = $(MERGE_META_LUA) $(UTILS_LUA) $(FILE_READING_LUA) $(BIBHANDLER_LUA) $(RELATION_REGISTRY_LUA) $(RELATION_GRAPH_LUA)

# === SOURCE FILES AND INTERMEDIATE FILES ===
TEX_FILES  := $(wildcard $(SRC_DIR)/*.tex)
PRE_TEX    := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.pre.tex,$(TEX_FILES))
JSON_FILES := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.json,$(TEX_FILES))
HTML_FILES := $(patsubst $(SRC_DIR)/%.tex,$(WWW_DIR)/%.htm,$(TEX_FILES))
TIMESTAMP_FILES := $(patsubst $(SRC_DIR)/%.tex,$(TEMP_DIR)/%.timestamp,$(TEX_FILES))
ASSET_FILES := $(shell find $(ASSETS_DIR) -type f -print)

# === GENERATED OUTPUTS ===
REFS_JSON     := $(TEMP_DIR)/bibliography.json
BIBTEX_JSON   := $(TEMP_DIR)/bibtex-entries.json
LABELS_JSON   := $(TEMP_DIR)/site-labels.json
POLYDATA_JSON := $(TEMP_DIR)/site-polydata.json
TODOS_JSON    := $(TEMP_DIR)/site-todo.json
SITEMAP_XML   := $(WWW_DIR)/sitemap.xml
GOTO_HTML     := $(WWW_DIR)/goto.htm
PUBLIC_LABELS_JSON := $(WWW_DIR)/site-labels.json
PUBLIC_KEYWORDS_JSON := $(WWW_DIR)/site-keywords.json
PUBLIC_BIB_JSON := $(WWW_DIR)/bibliography.json
RELATION_GRAPH_HTML := $(WWW_DIR)/polynomial-relations.htm
RELATION_GRAPH_JSON := $(WWW_DIR)/polynomial-relations.json
COPY_ASSETS_STAMP := $(TEMP_DIR)/copy-assets.stamp
META_STAMP := $(TEMP_DIR)/meta.stamp

# === EXPORTS FOR SCRIPTS ===
export PROJECT SRC_DIR ASSETS_DIR SCRIPTS_DIR TEMP_DIR WWW_DIR SITE_PATH SITE_BASE_URL
export SOURCE_REPOSITORY SOURCE_BRANCH ENABLE_RELATION_GRAPH
export TEMPLATE REFS_JSON BIBTEX_JSON LABELS_JSON POLYDATA_JSON TODOS_JSON SITEMAP_XML
export RELATION_GRAPH_HTML RELATION_GRAPH_JSON
