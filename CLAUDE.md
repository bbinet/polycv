# polycv

Typst CV package. Data-driven: all personal info lives in TOML files; `.typ` templates stay untouched.

## Structure

- `src/` - package source (`cv.typ`, `letter.typ`, `lib.typ`)
- `template/` - user-facing template files (`cv.typ`, `letter.typ`, `application.typ`, `cv.toml`, `letter.toml`, `cv.yml`, `letter.yml`)
- `schema/` - CUE schema + generated `schema.json` for TOML/YAML validation
- `typst.toml` - package manifest

## Key commands

```sh
make build-examples  # link, compile the shipped sample templates, unlink
make build           # compile content/ data files (personal, gitignored)
make watch           # live-preview content/ + re-validate on change
make spell           # cspell on toml files and README
make link            # symlink package into @preview cache
make bump-patch      # (or bump-minor / bump-major) bump version across all files
make prek            # run all pre-commit hooks
```

## Versioning

`bump-my-version` coordinates version across: `typst.toml`, template imports, schema URLs in TOMLs, README badge and init command. Always use `make bump-*` - never edit versions manually.

## Schema

`schema/schema.cue` is the source of truth. `schema/schema.json` is generated - edit the `.cue` file and run `make schema`.

## Fonts

Requires **IBM Plex Sans** and **Font Awesome 7 Free** installed as system fonts (not bundled).
