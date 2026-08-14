.DEFAULT_GOAL := help
.PHONY: help build build-examples build-layouts validate watch thumbs clean spell schema yaml-reference link unlink sync test-yaml prek prek-ci ci

# ---------------------------------------------------------------------------
# Version & platform
# ---------------------------------------------------------------------------
VERSION := $(shell grep '^version' typst.toml | sed 's/version = "\(.*\)"/\1/')
UNAME   := $(shell uname)
ifeq ($(UNAME),Darwin)
  DATA_DIR := $(HOME)/Library/Application Support
else
  DATA_DIR := $(or $(XDG_DATA_HOME),$(HOME)/.local/share)
endif
PREVIEW_TARGET := $(DATA_DIR)/typst/packages/preview/polycv/$(VERSION)

# ---------------------------------------------------------------------------
# Source files — any change triggers recompile of dependent PDFs
# ---------------------------------------------------------------------------
SRC_TYPS := $(wildcard src/*.typ)

# Tagged PDF (PDF/UA-1): logical reading order + document title, improves
# ATS text extraction and accessibility.
PDF_FLAGS := --pdf-standard ua-1

# ---------------------------------------------------------------------------
# Dynamic PDF rules
# $1 = data file path, $2 = path prefix as seen from template/ (e.g. ../content/)
# ---------------------------------------------------------------------------
_has_tmpl = $(if $(wildcard template/$(firstword $(subst -, ,$(basename $(notdir $1)))).typ),$1)

define PDF_RULE
$(eval _b := $(basename $(notdir $1)))
$(eval _p := $(firstword $(subst -, ,$(_b))))
$(eval _t := template/$(_p).typ)
$(eval _f := $(if $(filter .toml,$(suffix $1)),toml,yaml))
$(eval _o := $3$(_b).pdf)
$(_o): $1 $(_t) $(SRC_TYPS) $4
	@mkdir -p $$(dir $$@)
	@echo "  compiling: $(_b).pdf"
	typst compile $(_t) $(_o) --root . $$(PDF_FLAGS) --input "data=$2$(notdir $1)" --input "fmt=$(_f)"

endef

# The file a data file inherits from (`inherit:` value, resolved relative to
# it), and its full ancestor chain. A PDF depends on its ancestors, so editing
# a parent rebuilds only the files that inherit it — not unrelated CVs.
_inherit   = $(shell [ -f '$1' ] && sed -n 's/^[[:space:]]*inherit:[[:space:]]*//p' '$1' | head -n1)
_parent    = $(strip $(if $(call _inherit,$1),$(dir $1)$(call _inherit,$1)))
_ancestors = $(if $(call _parent,$1),$(call _parent,$1) $(call _ancestors,$(call _parent,$1)))

# --- content/ : personal data (gitignored) → out/ ---
_c_yml      := $(wildcard content/*.yml)
_c_toml     := $(wildcard content/*.toml)
_c_toml_only := $(filter-out $(patsubst content/%.yml,content/%.toml,$(_c_yml)),$(_c_toml))
CONTENT_DATA := $(foreach f,$(_c_yml) $(_c_toml_only),$(call _has_tmpl,$f))
CONTENT_PDFS :=
$(foreach f,$(CONTENT_DATA),$(eval $(call PDF_RULE,$f,../content/,out/,$(call _ancestors,$f))))
$(foreach f,$(CONTENT_DATA),$(eval CONTENT_PDFS += out/$(basename $(notdir $f)).pdf))

# --- template/ : sample data shipped with the template (committed) → out/examples/ ---
_e_yml      := $(wildcard template/*.yml)
_e_toml     := $(wildcard template/*.toml)
_e_toml_only := $(filter-out $(patsubst template/%.yml,template/%.toml,$(_e_yml)),$(_e_toml))
EXAMPLES_DATA := $(foreach f,$(_e_yml) $(_e_toml_only),$(call _has_tmpl,$f))
EXAMPLES_PDFS :=
$(foreach f,$(EXAMPLES_DATA),$(eval $(call PDF_RULE,$f,,out/examples/)))
$(foreach f,$(EXAMPLES_DATA),$(eval EXAMPLES_PDFS += out/examples/$(basename $(notdir $f)).pdf))

# --- data sets validated against schema.cue via `cue vet` ---
# Per-target scopes; each build validates only what it compiles. The
# standalone `validate` target checks everything (VALIDATE_DATA default).
CONTENT_ALL_DATA  := $(_c_yml) $(_c_toml)
EXAMPLES_ALL_DATA := $(_e_yml) $(_e_toml)
VALIDATE_DATA     := $(CONTENT_ALL_DATA) $(EXAMPLES_ALL_DATA)

# --- layout variants : the four header modes → out/ ---
# $1 = variant suffix, $2 = extra --input flags
_LAYOUT_DATA := content/cv-brunobinet-fr.yml
_LAYOUT_DEPS := $(_LAYOUT_DATA) template/cv.typ $(SRC_TYPS)
LAYOUT_PDFS :=

define LAYOUT_RULE
out/cv-brunobinet-fr-$1.pdf: $(_LAYOUT_DEPS)
	@mkdir -p $$(dir $$@)
	@echo "  compiling: cv-brunobinet-fr-$1.pdf"
	typst compile template/cv.typ $$@ --root . $$(PDF_FLAGS) --input "data=../content/cv-brunobinet-fr.yml" $2
LAYOUT_PDFS += out/cv-brunobinet-fr-$1.pdf

endef

$(eval $(call LAYOUT_RULE,standard,--input "ats-split=false" --input "header-band=false"))
$(eval $(call LAYOUT_RULE,header-band-photo,--input "ats-split=false" --input "header-band=true" --input "keywords-lines=3" --input "header-band-summary=true"))
$(eval $(call LAYOUT_RULE,header-band-photo-sidebar-contact,--input "ats-split=false" --input "header-band=true" --input "keywords-lines=3" --input "header-band-summary=true" --input "header-band-contact=false"))
$(eval $(call LAYOUT_RULE,ats-split,--input "ats-split=true" --input "header-band=false"))

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------

help:
	@printf "%-22s %s\n" "build" "compile content/ data files"
	@printf "%-22s %s\n" "build-examples" "compile the template's shipped sample data"
	@printf "%-22s %s\n" "build-layouts" "compile the 3 header layout variants"
	@printf "%-22s %s\n" "validate" "validate data files against schema.cue (cue vet)"
	@printf "%-22s %s\n" "watch" "live-preview all content/ files (WATCH=one file)"
	@printf "%-22s %s\n" "thumbs" "generate combined thumbnail strip"
	@printf "%-22s %s\n" "clean" "remove build artifacts"
	@printf "%-22s %s\n" "spell" "spell check data files and README"
	@printf "%-22s %s\n" "schema" "regenerate schema/schema.json"
	@printf "%-22s %s\n" "yaml-reference" "print an annotated YAML field reference (stdout)"
	@printf "%-22s %s\n" "link" "symlink package into @preview cache"
	@printf "%-22s %s\n" "unlink" "remove symlink from @preview cache"
	@printf "%-22s %s\n" "sync" "sync dependencies to latest"
	@printf "%-22s %s\n" "bump-TYPE" "bump version (major/minor/patch)"
	@printf "%-22s %s\n" "release-TYPE" "bump, commit, tag, and push"
	@printf "%-22s %s\n" "test-yaml" "verify yaml and toml produce identical output"
	@printf "%-22s %s\n" "prek" "run all pre-commit hooks"
	@printf "%-22s %s\n" "prek-ci" "run pre-commit hooks (CI mode)"
	@printf "%-22s %s\n" "ci" "run full CI suite"

validate:
	@command -v cue >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1 || { \
	  echo "cue or python3 not found — skipping validation (see cuelang.org)"; \
	  exit 0; \
	}
	@echo "Validating data files against schema.cue..."
	@tmp=$$(mktemp); mv "$$tmp" "$$tmp.json"; tmp="$$tmp.json"; \
	for f in $(VALIDATE_DATA); do \
	  case "$$(basename $$f)" in \
	    cv*)     def='#CVSchema' ;; \
	    letter*) def='#LetterSchema' ;; \
	    *)       def='#UnifiedSchema' ;; \
	  esac; \
	  echo "  $$f ($$def)"; \
	  python3 schema/resolve.py "$$f" > "$$tmp" || { rm -f "$$tmp"; exit 1; }; \
	  cue vet -d "$$def" schema/schema.cue "$$tmp" || { rm -f "$$tmp"; exit 1; }; \
	done; \
	rm -f "$$tmp"
	@echo "OK: all data files valid"

build:
	@$(MAKE) --no-print-directory validate VALIDATE_DATA="$(CONTENT_ALL_DATA)"
	@$(MAKE) --no-print-directory link
	@echo "Building content/..."
	@$(MAKE) --no-print-directory $(CONTENT_PDFS)
	@$(MAKE) --no-print-directory unlink

build-examples:
	@$(MAKE) --no-print-directory validate VALIDATE_DATA="$(EXAMPLES_ALL_DATA)"
	@$(MAKE) --no-print-directory link
	@echo "Building sample data..."
	@$(MAKE) --no-print-directory $(EXAMPLES_PDFS)
	@$(MAKE) --no-print-directory unlink

build-layouts:
	@$(MAKE) --no-print-directory validate VALIDATE_DATA="$(_LAYOUT_DATA)"
	@$(MAKE) --no-print-directory link
	@echo "Building layout variants..."
	@$(MAKE) --no-print-directory $(LAYOUT_PDFS)
	@$(MAKE) --no-print-directory unlink

# Live-preview every content/ file at once (each with its template, in
# parallel; Ctrl-C stops them all). Set WATCH=content/<file>.yml for just one.
WATCH ?=
watch: link
	@mkdir -p out
	@trap 'kill 0' EXIT INT TERM; \
	files="$(WATCH)"; [ -n "$$files" ] || files="$(CONTENT_DATA)"; \
	for f in $$files; do \
	  b=$$(basename $$f); b=$${b%.*}; tmpl=$${b%%-*}; \
	  case "$$f" in *.toml) fmt=toml;; *) fmt=yaml;; esac; \
	  echo "  watching $$f -> out/$$b.pdf"; \
	  typst watch template/$$tmpl.typ out/$$b.pdf --root . \
	    --input data=../$$f --input fmt=$$fmt & \
	done; \
	wait

thumbs: link
	typst compile template/application.typ "thumbnail{p}.png" --ppi 150
	cp thumbnail1.png thumbnail.png
	magick thumbnail1.png thumbnail2.png thumbnail3.png +append thumbnail-all.png
	rm thumbnail1.png thumbnail2.png thumbnail3.png

clean:
	@echo "Cleaning build artifacts..."
	@find . -name "*.pdf" -not -path "./.git/*" -delete
	@rm -rf out/
	@echo "Done"

spell:
	cspell template/cv.toml template/letter.toml template/cv.yml template/letter.yml README.md --config cspell.toml

schema:
	$(MAKE) -C schema json

yaml-reference:
	@python3 template/gen-reference.py schema/schema.json

link:
	@mkdir -p "$(dir $(PREVIEW_TARGET))"
	ln -sfn "$(CURDIR)" "$(PREVIEW_TARGET)"
	@echo "linked to $(PREVIEW_TARGET)"

unlink:
	rm -rf "$(PREVIEW_TARGET)"
	@echo "unlinked $(PREVIEW_TARGET)"

sync:
	@echo "Syncing dependencies..."
	utpm ws sync
	@echo "Done"

bump-%:
	bump-my-version bump $*

release-%: bump-%
	git push
	git push --tags

test-yaml:
	@$(MAKE) --no-print-directory link
	@mkdir -p out
	@echo "Compiling YAML variant..."
	typst compile template/cv.typ "out/test-yaml{p}.png" --root . --ppi 150 --input data=cv.yml
	@echo "Compiling TOML variant..."
	typst compile template/cv.typ "out/test-toml{p}.png" --root . --ppi 150 --input data=cv.toml --input fmt=toml
	@echo "Comparing pages..."
	@for f in out/test-yaml*.png; do \
	  toml_f="$${f/test-yaml/test-toml}"; \
	  if ! magick compare -metric AE "$$f" "$$toml_f" null: 2>/dev/null; then \
	    echo "FAIL: $$f != $$toml_f"; \
	    exit 1; \
	  fi; \
	done
	@echo "OK: YAML and TOML outputs are pixel-identical"
	@rm -f out/test-yaml*.png out/test-toml*.png

prek:
	prek run --all-files

prek-ci:
	prek run --all-files --skip schema --skip typstyle --show-diff-on-failure --color always

ci: prek spell build-examples test-yaml clean
