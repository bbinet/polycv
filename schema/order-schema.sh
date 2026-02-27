#!/usr/bin/env bash
# order-schema.sh - Reorder JSON Schema properties to match schema.cue field order
# This script reads the property order from schema.cue and applies it to schema.json
# No hardcoding needed - just change the order in schema.cue!

set -euo pipefail

SCHEMA_DIR="$(dirname "$0")"
SCHEMA_CUE="$SCHEMA_DIR/schema.cue"

# Extract field order from a CUE type definition
# Returns a JSON array of field names in schema.cue order
get_field_order() {
    local type_name="$1"
    awk "/${type_name}: \\{/,/^}/" "$SCHEMA_CUE" | \
        grep -E '^[[:space:]]+[a-zA-Z_]' | \
        grep -v '//' | \
        sed -E 's/^[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)\??.*/\1/' | \
        jq -R -s 'split("\n") | map(select(length > 0))'
}

# Discover all type definitions in schema.cue (lines starting with #Name: {)
TYPES=$(grep -E '^#[A-Za-z]+: \{' "$SCHEMA_CUE" | sed -E 's/^(#[A-Za-z]+):.*/\1/')

# Build jq arguments and filter dynamically
JQ_ARGS=()
JQ_FILTER='
def reorder_props($order):
    . as $original |
    (reduce ($order[] | select($original[.] != null)) as $key ({}; . + {($key): $original[$key]}))
    + $original;
'

for type in $TYPES; do
    order=$(get_field_order "$type")
    # Create a safe variable name for jq (remove #)
    var_name=$(echo "$type" | tr -d '#' | tr '[:upper:]' '[:lower:]')
    JQ_ARGS+=(--argjson "$var_name" "$order")
    JQ_FILTER+=".[\"\$defs\"][\"$type\"].properties |= reorder_props(\$$var_name) |
.[\"\$defs\"][\"$type\"] += {\"x-tombi-table-keys-order\": \"schema\"} |
"
done

# Remove trailing pipe
JQ_FILTER="${JQ_FILTER%|
}"

# Apply the filter
jq "${JQ_ARGS[@]}" "$JQ_FILTER"
