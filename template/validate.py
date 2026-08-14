#!/usr/bin/env python3
"""Validate a polycv document against schema.json (JSON Schema, draft 2020-12).

Reads the resolved document as JSON on stdin — `make validate` gets it from
Typst (which loads the YAML/TOML and resolves any `inherit:` chain), so this
script needs only the standard library: no PyYAML, no jsonschema, no install.

It implements the subset of JSON Schema that schema.cue emits: $ref/$defs,
type, properties, required, additionalProperties, items, enum, const, anyOf,
allOf, minimum. Unknown keywords are ignored.

Usage: <json on stdin> | validate.py schema.json [label]
Exit status is non-zero if the document is invalid; errors go to stderr.
"""
import json
import sys

schema_path = sys.argv[1] if len(sys.argv) > 1 else "schema.json"
label = sys.argv[2] if len(sys.argv) > 2 else "<stdin>"
SCHEMA = json.load(open(schema_path))
DEFS = SCHEMA.get("$defs", {})


def resolve(node):
    """Follow a $ref to its definition; other nodes pass through."""
    while isinstance(node, dict) and "$ref" in node:
        node = DEFS[node["$ref"].split("/")[-1]]
    return node


def type_ok(value, expected):
    if expected == "object":
        return isinstance(value, dict)
    if expected == "array":
        return isinstance(value, list)
    if expected == "string":
        return isinstance(value, str)
    if expected == "boolean":
        return isinstance(value, bool)
    if expected == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    if expected == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if expected == "null":
        return value is None
    return True


def validate(value, node, path, errors):
    node = resolve(node)
    if not isinstance(node, dict):
        return

    if "const" in node and value != node["const"]:
        errors.append(f"{path}: must be {node['const']!r}, got {value!r}")
    if "enum" in node and value not in node["enum"]:
        allowed = ", ".join(repr(v) for v in node["enum"])
        errors.append(f"{path}: {value!r} is not one of {allowed}")

    if "type" in node and not type_ok(value, node["type"]):
        errors.append(f"{path}: expected {node['type']}, got {json_type(value)}")
        return  # a wrong base type makes deeper checks meaningless

    if "allOf" in node:
        for sub in node["allOf"]:
            validate(value, sub, path, errors)
    if "anyOf" in node:
        branches = [[] for _ in node["anyOf"]]
        for sub, errs in zip(node["anyOf"], branches):
            validate(value, sub, path, errs)
        if all(errs for errs in branches):  # none matched
            opts = " | ".join(typename(resolve(s)) for s in node["anyOf"])
            errors.append(f"{path}: {value!r} matches none of: {opts}")

    if isinstance(value, (int, float)) and "minimum" in node and value < node["minimum"]:
        errors.append(f"{path}: {value} is below minimum {node['minimum']}")

    if isinstance(value, dict):
        props = node.get("properties", {})
        for key in node.get("required", []):
            if key not in value:
                errors.append(f"{path}: missing required field '{key}'")
        ap = node.get("additionalProperties", True)
        for key, val in value.items():
            child = f"{path}.{key}" if path else key
            if key in props:
                validate(val, props[key], child, errors)
            elif ap is False:
                errors.append(f"{path or '<root>'}: unknown field '{key}'")
            elif isinstance(ap, dict):
                validate(val, ap, child, errors)

    if isinstance(value, list) and "items" in node:
        for i, item in enumerate(value):
            validate(item, node["items"], f"{path}[{i}]", errors)


def json_type(value):
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, str):
        return "string"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, dict):
        return "object"
    if isinstance(value, list):
        return "array"
    return "null"


def typename(node):
    if "type" in node:
        return node["type"]
    if "enum" in node:
        return "enum"
    return "value"


def dedupe(errors):
    """Drop repeats, and collapse the several type errors an `allOf` can raise
    for one field (e.g. `number & integer`) into the first one."""
    seen, out = set(), []
    for e in errors:
        path = e.split(":", 1)[0]
        key = (path, "type") if "expected " in e and " got " in e else e
        if key not in seen:
            seen.add(key)
            out.append(e)
    return out


def main():
    try:
        doc = json.load(sys.stdin)
    except json.JSONDecodeError as e:
        sys.stderr.write(f"{label}: could not read document as JSON ({e})\n")
        return 1
    errors = []
    validate(doc, SCHEMA, "", errors)
    errors = dedupe(errors)
    if errors:
        sys.stderr.write(f"{label}: invalid\n")
        for e in errors:
            sys.stderr.write(f"  {e}\n")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
