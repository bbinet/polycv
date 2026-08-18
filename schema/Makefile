.DEFAULT_GOAL := json
.PHONY: json draft-2020 order fmt ship

# Regenerate schema.json, ship it into the package, refresh the field reference
json: draft-2020 order ship

# Ship the schema into src/ (read by the package for compile-time validation)
# and regenerate the static field reference shipped with the template.
ship:
	cp schema.json ../src/schema.json
	{ echo '# polycv field reference'; echo; echo '```yaml'; \
	  python3 gen-reference.py schema.json; echo '```'; } > ../template/FIELDS.md
	@echo "shipped schema.json -> ../src/ ; FIELDS.md -> ../template/"

# Generate schema.json from schema.cue (JSON Schema draft 2020-12)
draft-2020: fmt
	@echo "Regenerating schema.json from CUE..."
	cue export --out jsonschema -e '#UnifiedSchema' schema.cue > schema.json
	@echo "schema.json regenerated"

# Order all schema properties to match schema.cue field order (for tombi)
order:
	./order-schema.sh < schema.json > schema.json.tmp && mv schema.json.tmp schema.json
	@echo "schema.json keys successfully ordered"

# Format schema.cue
fmt:
	cue fmt schema.cue
	@echo "schema.cue formatted"
