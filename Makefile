.DEFAULT_GOAL := help
.PHONY: help build build-examples watch thumbs clean spell schema link unlink sync test-yaml prek prek-ci ci

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
PREVIEW_TARGET := $(DATA_DIR)/typst/packages/preview/nabcv/$(VERSION)

# ---------------------------------------------------------------------------
# Source files — any change triggers recompile of dependent PDFs
# ---------------------------------------------------------------------------
SRC_TYPS := $(wildcard src/*.typ)

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
$(_o): $1 $(_t) $(SRC_TYPS)
	@mkdir -p $$(dir $$@)
	@echo "  compiling: $(_b).pdf"
	typst compile $(_t) $(_o) --root . --input "data=$2$(notdir $1)" --input "fmt=$(_f)"

endef

# --- content/ : personal data (gitignored) → out/ ---
_c_yml      := $(wildcard content/*.yml)
_c_toml     := $(wildcard content/*.toml)
_c_toml_only := $(filter-out $(patsubst content/%.yml,content/%.toml,$(_c_yml)),$(_c_toml))
CONTENT_DATA := $(foreach f,$(_c_yml) $(_c_toml_only),$(call _has_tmpl,$f))
CONTENT_PDFS :=
$(foreach f,$(CONTENT_DATA),$(eval $(call PDF_RULE,$f,../content/,out/)))
$(foreach f,$(CONTENT_DATA),$(eval CONTENT_PDFS += out/$(basename $(notdir $f)).pdf))

# --- template/examples/ : sample data (committed) → out/examples/ ---
_e_yml      := $(wildcard template/examples/*.yml)
_e_toml     := $(wildcard template/examples/*.toml)
_e_toml_only := $(filter-out $(patsubst template/examples/%.yml,template/examples/%.toml,$(_e_yml)),$(_e_toml))
EXAMPLES_DATA := $(foreach f,$(_e_yml) $(_e_toml_only),$(call _has_tmpl,$f))
EXAMPLES_PDFS :=
$(foreach f,$(EXAMPLES_DATA),$(eval $(call PDF_RULE,$f,examples/,out/examples/)))
$(foreach f,$(EXAMPLES_DATA),$(eval EXAMPLES_PDFS += out/examples/$(basename $(notdir $f)).pdf))

# ---------------------------------------------------------------------------
# Targets
# ---------------------------------------------------------------------------

help:
	@printf "%-22s %s\n" "build" "compile content/ data files"
	@printf "%-22s %s\n" "build-examples" "compile template/examples/ data files"
	@printf "%-22s %s\n" "watch" "watch cv.typ for changes"
	@printf "%-22s %s\n" "thumbs" "generate combined thumbnail strip"
	@printf "%-22s %s\n" "clean" "remove build artifacts"
	@printf "%-22s %s\n" "spell" "spell check data files and README"
	@printf "%-22s %s\n" "schema" "regenerate schema/schema.json"
	@printf "%-22s %s\n" "link" "symlink package into @preview cache"
	@printf "%-22s %s\n" "unlink" "remove symlink from @preview cache"
	@printf "%-22s %s\n" "sync" "sync dependencies to latest"
	@printf "%-22s %s\n" "bump-TYPE" "bump version (major/minor/patch)"
	@printf "%-22s %s\n" "release-TYPE" "bump, commit, tag, and push"
	@printf "%-22s %s\n" "test-yaml" "verify yaml and toml produce identical output"
	@printf "%-22s %s\n" "prek" "run all pre-commit hooks"
	@printf "%-22s %s\n" "prek-ci" "run pre-commit hooks (CI mode)"
	@printf "%-22s %s\n" "ci" "run full CI suite"

build:
	@$(MAKE) --no-print-directory link
	@echo "Building content/..."
	@$(MAKE) --no-print-directory $(CONTENT_PDFS)
	@$(MAKE) --no-print-directory unlink

build-examples:
	@$(MAKE) --no-print-directory link
	@echo "Building template/examples/..."
	@$(MAKE) --no-print-directory $(EXAMPLES_PDFS)
	@$(MAKE) --no-print-directory unlink

watch: link
	typst watch template/cv.typ out/cv.pdf

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
	cspell template/examples/cv.toml template/examples/letter.toml template/examples/cv.yml template/examples/letter.yml README.md --config cspell.toml

schema:
	$(MAKE) -C schema json

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
	typst compile template/cv.typ "out/test-yaml{p}.png" --root . --ppi 150 --input data=examples/cv.yml
	@echo "Compiling TOML variant..."
	typst compile template/cv.typ "out/test-toml{p}.png" --root . --ppi 150 --input data=examples/cv.toml --input fmt=toml
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
