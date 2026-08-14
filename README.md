# polycv

<div align="center">

![](thumbnail-all.png)

**A Typst package for not-a-boring CV — data-driven, fully configurable, two-column layout**

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](https://github.com/bbinet/polycv)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Typst](https://img.shields.io/badge/typst-%3E%3D0.14-orange)](https://typst.app)

</div>

A data-driven CV and cover letter package for Typst. All personal data lives in `.yml` or `.toml` files; the template `.typ` files stay clean and untouched. The package exposes two functions — `cv` and `letter` — composable into a single `application.typ`.

## Features

- **Data-driven** — personal data in `.yml` or `.toml` files, no source edits needed
- **Two templates** — `cv` and `letter`, composable into a single `application.typ`
- **Configurable sections** — reorder or drop any sidebar or main-column section
- **Any social network** — `profiles-config` maps network name → icon + URL base
- **i18n** — override `month-names` and `date-separator` for any locale
- **Typst-idiomatic** — named parameters, `#show: cv.with(...)` pattern

## Prerequisites

1. **Typst CLI** — follow the [official instructions](https://github.com/typst/typst#installation).
2. **Fonts** — polycv requires two font families installed as system fonts:

   **IBM Plex Sans**

   ```sh
   # Debian/Ubuntu (Bookworm+)
   sudo apt install fonts-ibm-plex

   # Manual (all platforms)
   mkdir -p ~/.local/share/fonts/ibm-plex
   curl -L https://github.com/IBM/plex/releases/latest/download/OpenType.zip \
     | unzip -j - "ibm-plex-sans/fonts/complete/ttf/*.ttf" -d ~/.local/share/fonts/ibm-plex/
   fc-cache -f
   ```

   **Font Awesome 7 Free**

   Download the **Free for Desktop** package from [fontawesome.com/download](https://fontawesome.com/download), then:

   ```sh
   mkdir -p ~/.local/share/fonts/font-awesome-7
   # extract the downloaded archive, then:
   cp path/to/fontawesome-free-*-desktop/otfs/*.otf ~/.local/share/fonts/font-awesome-7/
   fc-cache -f
   ```

## Quick Start

### 1. Initialize

```sh
typst init @preview/polycv:0.1.0
```

This creates a `polycv/` folder with `cv.typ`, `letter.typ`, `application.typ` and their data files.

### 2. Install editor extensions (optional)

For schema-aware autocompletion and validation:

- **YAML** — [YAML by Red Hat](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml) validates `cv.yml` and `letter.yml` against `schema/schema.json`.
- **TOML** — [Tombi](https://marketplace.visualstudio.com/items?itemName=tombi-toml.tombi) validates `cv.toml` and `letter.toml`.

### 3. Fill in your data

Edit `cv.yml` (default format):

```yaml
cv:
  name: "Jane Smith"
  headline: "Software Engineer"
  email: "jane@example.com"
  phone: "+1 555 000 0000"
  summary: "Brief professional summary."
  profiles:
    - network: LinkedIn
      username: janesmith
  experience:
    - company: "Acme Corp"
      position: "Senior Engineer"
      start_date: "2021-03"
      end_date: "present"
      highlights:
        - "Built thing"
        - "Improved other thing"
```

Or use the TOML equivalent in `cv.toml`:

```toml
[cv]
name     = "Jane Smith"
headline = "Software Engineer"
email    = "jane@example.com"
phone    = "+1 555 000 0000"
summary  = "Brief professional summary."

[[cv.profiles]]
network  = "LinkedIn"
username = "janesmith"

[[cv.experience]]
company    = "Acme Corp"
position   = "Senior Engineer"
start_date = "2021-03"
end_date   = "present"
highlights = ["Built thing", "Improved other thing"]
```

Edit `letter.yml` (or `letter.toml`) similarly for your cover letter.

### 4. Compile

```sh
# YAML data (default)
typst compile cv.typ
typst compile letter.typ
typst compile application.typ

# TOML data
typst compile cv.typ --input fmt=toml
typst compile letter.typ --input fmt=toml
typst compile application.typ --input fmt=toml
```

The initialized project also ships a `Makefile` with shortcuts:

```sh
make                              # build every cv*.yml / letter*.yml that changed
make watch                        # live-preview them all (WATCH=<file> for one)
make yaml-reference               # print every available field, its type and doc
```

`make` rebuilds only the files whose source changed. The prefix before the first `-` picks the template, so a **bilingual CV** is just two files: name them `cv-en.yml` and `cv-fr.yml` (set `meta: locale` in each). The same applies to letters (`letter-en.yml`, …).

### 5. Customize for a company (optional)

A customized CV is just another data file that **inherits** a base and overrides only what changes. Add `cv-acme.yml`:

```yaml
inherit: cv.yml                                      # or cv-fr.yml — path relative to this file
cv:
  headline: "Backend Engineer — Distributed Systems"
  keywords: ["Go", "Kubernetes", "observability"]    # replaces the base list
  experience:
    - highlights:
        - ~                                           # keep base highlight 0
        - "Rephrased for Acme"                        # replace highlight 1
```

`make` compiles it to `cv-acme.pdf` like any other file — no special command. The parent is deep-merged: dictionaries merge key by key, arrays by index, other values are replaced, and `~` (null) at an array position keeps the base item. Inheritance can chain (`cv-acme.yml` → `cv-fr.yml` → `cv.yml`), and a change to a base propagates to everything that inherits it.

A customized letter works the same way — `letter-acme.yml` with `inherit: letter.yml` keeps the `sender` and overrides `recipient`, `subject` and `body`.

## Templates

| File               | Description                                             |
| ------------------ | ------------------------------------------------------- |
| `cv.typ`           | Standalone CV using `#show: cv.with(...)`               |
| `letter.typ`       | Standalone cover letter using `#show: letter.with(...)` |
| `application.typ`  | CV followed by letter in a single PDF                   |
| `cv.yml`           | CV data in YAML (personal info, experience, education, …) |
| `letter.yml`       | Letter data in YAML (sender, recipient, body paragraphs)  |
| `cv.toml`          | CV data in TOML (alternative format, `--input fmt=toml`)  |
| `letter.toml`      | Letter data in TOML (alternative format)                  |

## Layouts

The CV offers four header layouts, selectable without touching any `.typ` file — either from the command line or from the `meta:` block of your data file.

| Layout | Flags | Description |
| ------ | ----- | ----------- |
| **Standard** | _(none)_ | Name and headline at the top of the main column, photo and contact in the tinted sidebar |
| **Header band** | `header-band: true` | Full-width header: round photo on the left (sized to the text block height), name, headline and a one-line contact row; no sidebar tint |
| **ATS split** | `ats-split: true` | Two-column header (photo left, name/headline right), sidebar keeps the tint; friendlier to ATS parsers |

![The standard, header-band and ATS-split layouts side by side](thumbnail-layouts.png)

*Left to right, all from the same data: **Standard** · **Header band** with the summary inside the band · **ATS split** rendered in French with inline entry dates and no timeline.*

The header can be tuned further: `header-band-summary: true` moves the summary into the header (works with both header-band and ats-split), and `header-band-contact: false` keeps the contact section in the sidebar instead of the band's contact line.

Via command line:

```sh
typst compile cv.typ --input header-band=true --input keywords-lines=3
```

Or via the `meta:` block in `cv.yml` (command-line inputs take priority):

```yaml
meta:
  photo: photo.jpg           # path to your photo
  locale: fr                 # translates section titles and month names
  header-band: true          # pick a layout
  header-band-summary: true  # summary inside the band
  keywords-lines: 3          # distribute keyword badges over 3 lines
```

Available meta/input keys: `data`, `fmt`, `photo`, `locale` (`en`/`fr`), `header-band`, `header-band-summary`, `header-band-contact`, `ats-split`, `keywords-lines` (0 = one badge per line), `entry-inline-meta`, `show-timeline`, `sidebar-sections`, `main-sections`, `section-titles`, `section-icons`.

## Customization

All customization is done through named parameters in the template `.typ` file. Nothing in `src/` needs to be touched.

### Section order

```typ
#show: cv.with(
  ...,
  sidebar-sections: ("contact", "skills", "values", "references"),
  main-sections:    ("experience", "education", "summary", "courses"),
)
```

Omit a key to hide that section entirely. A section can live in either column: for example, put `"education"` in `sidebar-sections` and it renders as a compact block (degree, institution, location · dates) instead of the wide timeline.

With the provided template, set these lists in the `meta:` block of your data file instead of editing the `.typ`:

```yaml
meta:
  sidebar-sections: ["photo", "contact", "education", "skills"]
  main-sections: ["summary", "experience", "awards", "courses"]
```

### Section titles & icons

```typ
#show: cv.with(
  ...,
  section-titles: (awards: "PRIZES & RECOGNITION", experience: "WORK HISTORY"),
  section-icons:  (awards: "medal", experience: "briefcase"),
)
```

Icon names are [FontAwesome 7](https://fontawesome.com/icons) identifiers.

With the provided template these are also settable from the `meta:` block (they override the built-in defaults, and any locale titles):

```yaml
meta:
  section-titles:
    awards: "ENGAGEMENTS"
  section-icons:
    awards: hand-holding-heart
    hobbies: person-running
```

### Social profiles

```typ
#show: cv.with(
  ...,
  profiles-config: (
    LinkedIn:  (icon: "linkedin",  url-base: "https://linkedin.com/in/"),
    GitHub:    (icon: "github",    url-base: "https://github.com/"),
Portfolio: (icon: "globe",     url-base: "https://"),
  ),
)
```

### Locale / i18n

```typ
#show: cv.with(
  ...,
  month-names:    ("jan.", "fév.", "mars", "avr.", "mai", "juin",
                   "juil.", "août", "sep.", "oct.", "nov.", "déc."),
  date-separator: " – ",
)
```

### Theming

```typ
#show: cv.with(
  ...,
  theme: (secondary: rgb("#B71C1C"), sidebar-bg: rgb("#FFF8F8")),
)
```

Available keys:

| Key | Default | Description |
| --- | ------- | ----------- |
| `primary` | `#000000` | Main text colour |
| `secondary` | `#0D47A1` | Section titles and keyword badges |
| `accent` | `#000000` | Dates, entry summaries, headline |
| `links` | `#1565C0` | Hyperlinks |
| `sidebar-bg` | `#F5F1ED` | Sidebar tint (standard and ats-split layouts) |
| `summary` | `#6B6B6B` | Summary text and header contact line |
| `header-bg` | `white` | Header band background (`none` = transparent) |
| `header-rule` | `none` | Horizontal rule under the header band |
| `sidebar-rule` | `none` | Vertical rule between the columns (header-band layouts) |

With header-band layouts the sidebar tint is dropped; set `header-rule` and/or `sidebar-rule` to a colour (e.g. `rgb("#D5D5D5")`) to draw separators instead.

### Other parameters

| Parameter          | Default           | Description                              |
| ------------------ | ----------------- | ---------------------------------------- |
| `show-header-band` | `false`           | Full-width header band layout (photo at its left) |
| `header-band-summary` | `false`        | Summary inside the header band           |
| `header-band-contact` | `true`         | Contact line in the band (false = sidebar) |
| `ats-split`        | `false`           | Two-column header layout                 |
| `keywords-lines`   | `auto`            | Lines for keyword badges (`auto` = one per line) |
| `photo-size`       | `70%`             | Photo diameter as a fraction of sidebar width (ignored by the header band, which sizes the photo to the text block height) |
| `bullet-icon`      | `"angle-right"`   | Icon for all list bullets                |
| `address-icon`     | `"location-dot"`  | Icon for address field                   |
| `doi-icon`         | `"external-link"` | Icon on publication DOI links            |
| `show-timeline`    | `true`            | Toggle the dots + vertical line on experience/education entries |
| `entry-inline-meta`| `false`           | Company + location/dates on the title line (dates right-aligned), position below |
| `justify-sidebar`  | `false`           | Justify text in the sidebar              |
| `skill-icons`      | _(defaults)_      | Map skill group names to icons           |
| `text-size`        | _(defaults)_      | Override any font size by key            |
| `font-weight`      | _(defaults)_      | Override any font weight by key          |

For the letter:

| Parameter           | Default                          | Description                            |
| ------------------- | -------------------------------- | -------------------------------------- |
| `footer-items`      | `("phone", "email", "linkedin")` | Fields shown in the page footer        |
| `contact-icons`     | _(defaults)_                     | Icon names for contact fields          |
| `contact-url-bases` | _(defaults)_                     | URL prefixes for email/linkedin/github |

## Development

### Setup

```sh
git clone https://github.com/bbinet/polycv
cd polycv
make build          # compile every content/ file (incremental)
make watch          # live-preview all content/ files (WATCH=one file)
make build-examples # compile the shipped sample data only
make build-layouts  # compile the header layout variants side by side
make validate       # validate data files against schema.cue (cue vet)
make yaml-reference # print an annotated reference of every CV field
```

Personal data files go in `content/` (gitignored). The **prefix before the first `-`** selects the template: `cv-<slug>.yml` → `cv.typ`, `letter-<slug>.yml` → `letter.typ` (a file whose prefix has no matching `template/<prefix>.typ` is skipped). `make build` compiles every such file, and `make watch` live-previews them all. Every build validates its data against the schema first.

### Customizing a CV per company

Same `inherit:` mechanism as [Quick Start §5](#5-customize-for-a-company-optional), on your `content/` CVs: add `content/cv-fr-acme.yml` with `inherit: cv-fr.yml` and the overrides — `make build` builds it to `out/cv-fr-acme.pdf`. Validation first resolves the `inherit:` chain (`schema/resolve.py`) and checks the **merged** document, so customized files are validated as the complete CV they produce, not skipped.

`make yaml-reference` prints a commented YAML skeleton listing every field, its type, whether it is required, and a one-line description — generated from the schema so it never drifts. It documents the structure; for a filled example see `template/cv.yml`.

### Dependencies

| Tool | Purpose |
| ---- | ------- |
| `typst` | Compiler |
| `make` | Build orchestration |
| `cue` | Schema authoring + data validation (`make schema`, `make validate`) |
| `jq` | Schema key ordering (`make schema`) |
| `python3` | Inherit resolver for validation + field reference (`make validate`, `make yaml-reference`) |
| `bump-my-version` | Version bumping (`make bump-patch`) |
| `cspell` | Spell checking (`make spell`) |
| `imagemagick` | Pixel-diffing the YAML vs TOML output (`make test-yaml`) — optional |

A `shell.nix` is provided for a reproducible environment with all tools and font paths pre-configured.

### Claude Code (nono sandbox)

If you use [Claude Code](https://claude.ai/code) with the [nono](https://github.com/always-further/nono) sandbox, a ready-made profile is included at `.claude/nono-profile-claude-typst.json`. It grants the sandbox access to the Typst package cache and system fonts.

```sh
cp .claude/nono-profile-claude-typst.json ~/.config/nono/profiles/claude-typst.json
nono run --profile claude-typst -- claude
```

## Inspirations

- [brilliant-CV](https://github.com/yunanwg/brilliant-CV) — a well-crafted Typst CV package that inspired the overall structure and development workflow of this project
- [hipster-cv](https://github.com/latex-ninja/hipster-cv) — a LaTeX CV template that inspired the two-column sidebar design
- [acadennial-cv](https://github.com/whliao5am/acadennial-cv-typst-template) — a Typst academic CV template

## Credits

polycv began as a fork of [nabcv](https://github.com/xrsl/nabcv) (*not-a-boring
CV*) by xrsl, and keeps its clean two-column, data-driven foundation. The main
additions since:

- **YAML as well as TOML** for the data files, with identical output
- **A `meta` block** to configure the layout from data alone — locale (incl. a
  French preset), section order and placement, per-section titles and icons
- **ATS-friendly layouts** — an `ats-split` single-column mode and a horizontal
  header band (photo / summary / contact variants) for better text extraction
- **Tagged PDF/UA-1 output** for accessibility and reliable ATS parsing
- **A `volunteering` section**, inline entry metadata, and a toggleable timeline
- **A schema** (CUE → JSON Schema) driving editor autocomplete, `make validate`,
  and `make yaml-reference` (a generated, annotated list of every field)
- **Per-company customization** via `inherit:` — a variant file overrides only
  what changes and deep-merges over its parent
- **Incremental Makefiles**, including one shipped with `typst init`, that
  rebuild only what changed (and, on a parent edit, only its inheritors)

## License

[MIT](LICENSE)
