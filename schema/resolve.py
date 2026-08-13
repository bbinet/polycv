#!/usr/bin/env python3
"""Resolve a data file's `inherit:` chain and print the merged JSON.

Used by `make validate` so a customized (partial) file is checked as the
complete document it produces, rather than being skipped. Files are loaded
with `cue export` (which reads yaml, toml and json), so no extra deps.

Merge semantics mirror the template's deep-merge: dicts merge key by key,
arrays by index, other values are replaced, and null keeps the parent value.
"""
import json
import os
import subprocess
import sys


def load(f):
    r = subprocess.run(
        ["cue", "export", f, "--out", "json"], capture_output=True, text=True
    )
    if r.returncode != 0:
        sys.stderr.write(r.stderr)
        sys.exit(1)
    return json.loads(r.stdout)


def deep_merge(base, over):
    if over is None:
        return base
    if isinstance(base, dict) and isinstance(over, dict):
        out = dict(base)
        for k, v in over.items():
            out[k] = deep_merge(base.get(k), v)
        return out
    if isinstance(base, list) and isinstance(over, list):
        n = max(len(base), len(over))
        return [
            deep_merge(
                base[i] if i < len(base) else None,
                over[i] if i < len(over) else None,
            )
            for i in range(n)
        ]
    return over


def resolve(f):
    raw = load(f)
    parent = raw.get("inherit")
    if parent is None:
        return raw
    child = {k: v for k, v in raw.items() if k != "inherit"}
    parent_path = os.path.normpath(os.path.join(os.path.dirname(f), parent))
    return deep_merge(resolve(parent_path), child)


print(json.dumps(resolve(sys.argv[1])))
