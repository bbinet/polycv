.DEFAULT_GOAL := json
.PHONY: json draft-2020 order fmt

# Regenerate schema.json from schema.cue
json: draft-2020 order

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
