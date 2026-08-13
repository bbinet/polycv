# Helpers for documents created with `typst init @preview/nabcv`.
#   make            → build every cv*/letter* whose source changed
#   make watch      → live-preview them all (WATCH=<file> for one; Ctrl-C stops)
#   make yaml-reference → print every available field, its type and doc (stdout)
#
# The prefix before the first '-' picks the template (cv-*.yml → cv.typ,
# letter-*.yml → letter.typ), so a bilingual CV is just cv-en.yml / cv-fr.yml
# (set `meta: locale` in each). To customize for a company, add a data file that
# declares its parent, e.g. cv-acme.yml with `inherit: cv-fr.yml` and only the
# fields that differ; editing a parent rebuilds everything that inherits it.
# Set FMT=toml to use the .toml data files.
FMT ?= yaml
EXT := $(if $(filter toml,$(FMT)),toml,yml)
WATCH ?=

CV_SRCS  := $(wildcard cv*.$(EXT))
LET_SRCS := $(wildcard letter*.$(EXT))
CV_PDFS  := $(CV_SRCS:.$(EXT)=.pdf)
LET_PDFS := $(LET_SRCS:.$(EXT)=.pdf)

.DEFAULT_GOAL := build
.PHONY: build watch yaml-reference

build: $(CV_PDFS) $(LET_PDFS)

# Each PDF depends on every source of its kind, so editing a parent (that a
# cv-*.yml inherits) rebuilds the files that inherit it.
$(CV_PDFS): %.pdf: %.$(EXT) $(CV_SRCS) cv.typ
	typst compile cv.typ $@ --input data=$< --input fmt=$(FMT)

$(LET_PDFS): %.pdf: %.$(EXT) $(LET_SRCS) letter.typ
	typst compile letter.typ $@ --input data=$< --input fmt=$(FMT)

watch:
	@files="$(WATCH)"; [ -n "$$files" ] || files="$(wildcard cv*.$(EXT)) $(wildcard letter*.$(EXT))"; \
	echo "Watching $$files (Ctrl-C to stop)..."; \
	trap 'kill 0' EXIT INT TERM; \
	for f in $$files; do \
	  tmpl=$${f%.*}; tmpl=$${tmpl%%-*}; \
	  typst watch $$tmpl.typ $${f%.*}.pdf --input data=$$f --input fmt=$(FMT) & \
	done; \
	wait

# Field reference, fetched from the schema URL declared in cv.yml (needs network).
yaml-reference:
	@url=$$(grep -om1 'https://[^ ]*schema\.json' cv.yml); \
	python3 gen-reference.py "$$url"
