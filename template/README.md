# My CV & cover letter

Created from the [polycv](https://github.com/bbinet/polycv) Typst template.
It's data-driven: you fill in the YAML (or TOML) files and compile. For everyday
changes you don't edit the `.typ` files - but they're yours to tweak for advanced
options (colours, fonts...); see the [polycv README](https://github.com/bbinet/polycv#advanced-template-parameters).
Only the polycv package itself is off-limits.

## Prerequisites

- [Typst](https://github.com/typst/typst) (`typst --version`)
- Fonts **IBM Plex Sans** and **Font Awesome 7 Free**, installed as system fonts
- `make` (optional, but the commands below assume it)

## Files

| File | What it is |
| --- | --- |
| `cv.yml` | Your CV data (personal info, experience, skills...) |
| `letter.yml` | A cover letter |
| `cv.typ`, `letter.typ`, `application.typ` | Entrypoints you compile (edit only for advanced options) |
| `.toml` variants | Same data in TOML, if you prefer it to YAML |

Pick **one** format and delete the other (`.yml` or `.toml`); mixing works but
is noise. To use TOML, pass `FMT=toml` to every `make` command.

## Build

```sh
make                 # validate, then compile every cv*/letter* that changed -> PDFs
make validate        # check each data file against the polycv schema
make watch           # live-preview them all + re-validate on change (Ctrl-C to stop)
make yaml-reference  # print every available field, its type and its doc
```

`make` only recompiles what changed - and when you edit a base file, only the
variants that inherit it. Add `FMT=toml` to work with the TOML files.

## Bilingual & per-company CVs

The filename prefix before the first `-` picks the template: `cv-*.yml` uses
`cv.typ`, `letter-*.yml` uses `letter.typ`. So a bilingual CV is just two
files, `cv-en.yml` and `cv-fr.yml` - both build automatically.

To customize a CV for one company without duplicating everything, create a
file that **inherits** from a base and overrides only what differs:

```yaml
# cv-acme.yml
inherit: cv.yml          # path relative to this file
cv:
  summary: A summary rewritten for Acme.
  experience:
    - ~                  # ~ (null) keeps the parent entry untouched
    - highlights:
        - ~
        - A highlight that speaks to Acme's needs.
```

The template deep-merges your file over the resolved parent (dicts by key,
arrays by index, `null`/`~` keeps the parent value). Inheritance chains, and a
customized file rebuilds whenever its parent changes.

## Validation

`make validate` (run automatically by `make`) checks every data file - catching
unknown fields, wrong types and invalid enum values on the fully resolved
document (inheritance included). It uses only Typst and Python 3, nothing to
install. The schema is the version-pinned one referenced in your data files
(`# yaml-language-server: $schema=...`), fetched once and cached locally (see
`.polycv-schema-<version>.json`), so it stays offline afterwards and always
matches the polycv version you use. The first fetch needs network access; if
it's unavailable, validation is skipped with a warning and the build proceeds.

Editors help too: thanks to that same `$schema` header, an editor with the
[YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
(or [Tombi](https://tombi-toml.github.io/tombi/) for TOML) extension validates
and autocompletes every field as you type.

## Files you can ignore

`validate.py`, `_schema.typ` and `gen-reference.py` power validation and
`make yaml-reference`; leave them as they are. Compile your documents from
`cv.typ`, `letter.typ` and `application.typ` (edit those only for the advanced
options linked above).
