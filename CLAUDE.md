# nabcv

Typst CV package. Data-driven: all personal info lives in TOML files; `.typ` templates stay untouched.

## Structure

- `src/` — package source (`cv.typ`, `letter.typ`, `lib.typ`)
- `template/` — user-facing template files (`cv.typ`, `letter.typ`, `application.typ`, `cv.toml`, `letter.toml`)
- `schema/` — CUE schema + generated `schema.json` for TOML validation
- `typst.toml` — package manifest

## Key commands

```sh
just build    # link, compile all templates, unlink
just watch    # link + typst watch cv.typ
just spell    # cspell on toml files and README
just link     # symlink package into @preview cache
just bump patch|minor|major  # bump version across all files
just prek     # run all pre-commit hooks
```

## Versioning

`bump-my-version` coordinates version across: `typst.toml`, template imports, schema URLs in TOMLs, README badge and init command. Always use `just bump` — never edit versions manually.

## Schema

`schema/schema.cue` is the source of truth. `schema/schema.json` is generated — edit the `.cue` file and run `just schema`.

## Fonts

Requires **IBM Plex Sans** and **Font Awesome 7 Free** installed as system fonts (not bundled).
