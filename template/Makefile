# Helpers for documents created with `typst init @preview/polycv`.
#   make            -> validate, then build every cv*/letter* whose source changed
#   make validate   -> check each data file against the polycv schema
#   make watch      -> live-preview them all (WATCH=<file> for one; Ctrl-C stops)
#   make yaml-reference -> print every available field, its type and doc (stdout)
#
# The prefix before the first '-' picks the template (cv-*.yml -> cv.typ,
# letter-*.yml -> letter.typ), so a bilingual CV is just cv-en.yml / cv-fr.yml
# (set `meta: locale` in each). To customize for a company, add a data file that
# declares its parent, e.g. cv-acme.yml with `inherit: cv-fr.yml` and only the
# fields that differ; editing a parent then rebuilds only what inherits it.
# Set FMT=toml to use the .toml data files.
FMT ?= yaml
EXT := $(if $(filter toml,$(FMT)),toml,yml)
WATCH ?=

CV_SRCS  := $(wildcard cv*.$(EXT))
LET_SRCS := $(wildcard letter*.$(EXT))
CV_PDFS  := $(CV_SRCS:.$(EXT)=.pdf)
LET_PDFS := $(LET_SRCS:.$(EXT)=.pdf)

# Schema: the version-pinned URL in the data files (bumped with the package) is
# the source of truth. We fetch it once and cache it locally (per version), so
# validation is offline afterwards and always matches the polycv version in use.
SCHEMA_URL   := $(shell sed -n 's/.*\(https:[^ ]*schema\.json\).*/\1/p' cv.$(EXT) letter.$(EXT) 2>/dev/null | head -n1)
_SCHEMA_VER  := $(shell printf '%s' '$(SCHEMA_URL)' | sed -n 's#.*/v\{0,1\}\([0-9][0-9.]*\)/.*#\1#p')
SCHEMA_CACHE := .polycv-schema$(if $(_SCHEMA_VER),-$(_SCHEMA_VER)).json

.DEFAULT_GOAL := build
.PHONY: build validate watch yaml-reference

build: validate $(CV_PDFS) $(LET_PDFS)

$(CV_PDFS): %.pdf: %.$(EXT) cv.typ
	typst compile cv.typ $@ --input data=$< --input fmt=$(FMT)

$(LET_PDFS): %.pdf: %.$(EXT) letter.typ
	typst compile letter.typ $@ --input data=$< --input fmt=$(FMT)

# The file a data file inherits from (`inherit:` value, resolved relative to
# it) and its full ancestor chain. A PDF also depends on its ancestors, so
# editing a parent rebuilds only what inherits it - not unrelated CVs.
_inherit   = $(shell [ -f '$1' ] && sed -n 's/^[[:space:]]*inherit:[[:space:]]*//p' '$1' | head -n1)
_parent    = $(strip $(if $(call _inherit,$1),$(dir $1)$(call _inherit,$1)))
_ancestors = $(if $(call _parent,$1),$(call _parent,$1) $(call _ancestors,$(call _parent,$1)))
$(foreach s,$(CV_SRCS) $(LET_SRCS),$(eval $(s:.$(EXT)=.pdf): $(call _ancestors,$s)))

# Fetch and cache the schema (Python's urllib - no curl/wget needed). Refetched
# only when the version, hence the cache filename, changes.
$(SCHEMA_CACHE):
	@[ -n "$(SCHEMA_URL)" ] || { echo "no \$$schema URL found in cv.$(EXT)/letter.$(EXT)" >&2; exit 1; }
	@echo "Fetching schema: $(SCHEMA_URL)"
	@python3 -c "import urllib.request,sys; open(sys.argv[2],'wb').write(urllib.request.urlopen(sys.argv[1],timeout=10).read())" '$(SCHEMA_URL)' '$@' \
	  || { echo "error: could not fetch schema (offline?)" >&2; rm -f '$@'; exit 1; }

# Validate each data file against the schema. _schema.typ loads the data,
# resolves any `inherit:` chain and prints the merged document as JSON, which
# validate.py checks - needs only typst + python3 (no extra installs). If the
# schema can't be fetched (offline, first run), validation is skipped with a
# warning instead of failing the build.
validate:
	@sch='$(SCHEMA_CACHE)'; url='$(SCHEMA_URL)'; \
	if [ ! -f "$$sch" ]; then \
	  if [ -n "$$url" ] && echo "Fetching schema: $$url" && \
	     python3 -c "import urllib.request,sys; open(sys.argv[2],'wb').write(urllib.request.urlopen(sys.argv[1],timeout=10).read())" "$$url" "$$sch" 2>/dev/null; then :; \
	  else \
	    echo "warning: schema unavailable (offline?) - skipping validation" >&2; rm -f "$$sch"; exit 0; \
	  fi; \
	fi; \
	ok=1; for f in $(CV_SRCS) $(LET_SRCS); do \
	  if json=$$(typst eval 'query(<polycv-data>).first().value' --in _schema.typ \
	      --input data=$$f --input fmt=$(FMT) --format json --root . 2>/dev/null); then \
	    printf '%s' "$$json" | python3 validate.py "$$sch" $$f || ok=0; \
	  else \
	    echo "$$f: could not be read (invalid $(FMT)?)" >&2; ok=0; \
	  fi; \
	done; \
	[ $$ok = 1 ] && echo "OK: all data files valid" || exit 1

watch:
	@files="$(WATCH)"; [ -n "$$files" ] || files="$(wildcard cv*.$(EXT)) $(wildcard letter*.$(EXT))"; \
	echo "Watching $$files (Ctrl-C to stop)..."; \
	trap 'kill 0' EXIT INT TERM; \
	for f in $$files; do \
	  tmpl=$${f%.*}; tmpl=$${tmpl%%-*}; \
	  typst watch $$tmpl.typ $${f%.*}.pdf --input data=$$f --input fmt=$(FMT) & \
	done; \
	wait

# Annotated field reference, read from the cached schema (fetched once).
yaml-reference: $(SCHEMA_CACHE)
	@python3 gen-reference.py '$(SCHEMA_CACHE)'
