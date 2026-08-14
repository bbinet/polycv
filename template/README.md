# My CV & cover letter

Created from the [polycv](https://github.com/bbinet/polycv) Typst template.
Everything is data-driven: edit the YAML (or TOML) files — never the `.typ`.

## Prerequisites

- [Typst](https://github.com/typst/typst) (`typst --version`)
- Fonts **IBM Plex Sans** and **Font Awesome 7 Free**, installed as system fonts
- `make` (optional, but the commands below assume it)

## Files

| File | What it is |
| --- | --- |
| `cv.yml` | Your CV data (personal info, experience, skills…) |
| `letter.yml` | A cover letter |
| `cv.typ`, `letter.typ`, `application.typ` | Templates — leave them alone |
| `.toml` variants | Same data in TOML, if you prefer it to YAML |

Pick **one** format and delete the other (`.yml` or `.toml`); mixing works but
is noise. To use TOML, pass `FMT=toml` to every `make` command.

## Build

```sh
make                 # compile every cv*/letter* whose source changed → PDFs
make watch           # live-preview them all while you edit (Ctrl-C to stop)
make yaml-reference  # print every available field, its type and its doc
```

`make` only recompiles what changed. Add `FMT=toml` to build the TOML files.

## Bilingual & per-company CVs

The filename prefix before the first `-` picks the template: `cv-*.yml` uses
`cv.typ`, `letter-*.yml` uses `letter.typ`. So a bilingual CV is just two
files, `cv-en.yml` and `cv-fr.yml` — both build automatically.

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

The YAML files carry a `# yaml-language-server: $schema=…` header, so an editor
with the [YAML](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
(or [Tombi](https://tombi-toml.github.io/tombi/) for TOML) extension validates
and autocompletes every field against the polycv schema as you type.
