// typst compile --root . template/cv.typ
#import "@preview/nabcv:0.1.0": cv

// --- Load data (fmt and data-file from sys.inputs, with sensible defaults) ---
#let fmt = sys.inputs.at("fmt", default: "yaml")
#let data-file = sys.inputs.at("data", default: if fmt == "toml" { "cv.toml" } else { "cv.yml" })
#let raw = if fmt == "yaml" { yaml(data-file) } else { toml(data-file) }
#let meta = raw.at("meta", default: (:))
#let cd = raw.cv

// --- Helpers: sys.inputs take priority, meta is the fallback ---
#let input-str(key, default: "") = sys.inputs.at(key, default: str(meta.at(key, default: default)))
#let input-bool(key, default: false) = {
  if key in sys.inputs { sys.inputs.at(key) == "true" }
  else { meta.at(key, default: default) }
}

#let photo-file = input-str("photo", default: "assets/avatar.svg")
#let header-band = input-bool("header-band")
#let header-band-summary = input-bool("header-band-summary")
#let header-band-contact = input-bool("header-band-contact", default: true)
#let ats-split = input-bool("ats-split")
#let entry-inline-meta = input-bool("entry-inline-meta")
#let locale = input-str("locale", default: "en")

// Optional section ordering from meta (arrays); omitted keys use cv() defaults.
// 0 = auto (one badge per line)
#let keywords-lines = int(input-str("keywords-lines", default: "0"))

#let locale-args = if locale == "fr" {
  (
    month-names: (
      "jan.", "fév.", "mars", "avr.", "mai", "juin",
      "juil.", "août", "sep.", "oct.", "nov.", "déc.",
    ),
    date-separator: " – ",
  )
} else { (:) }

#let locale-titles = if locale == "fr" {
  (
    contact: "CONTACT",
    skills: "COMPÉTENCES",
    values: "VALEURS",
    hobbies: "LOISIRS",
    references: "RÉFÉRENCES",
    publications: "PUBLICATIONS",
    summary: "RÉSUMÉ",
    motivation: "MOTIVATION",
    experience: "EXPÉRIENCE",
    education: "FORMATION",
    awards: "DISTINCTIONS",
    volunteering: "ENGAGEMENTS",
    courses: "FORMATIONS",
  )
} else { (:) }

// Section ordering / titles / icons from meta (all optional). section-titles
// merges over the locale titles so meta overrides win.
#let section-args = (:)
#if "sidebar-sections" in meta {
  section-args.insert("sidebar-sections", meta.sidebar-sections)
}
#if "main-sections" in meta {
  section-args.insert("main-sections", meta.main-sections)
}
#if "section-icons" in meta {
  section-args.insert("section-icons", meta.section-icons)
}
#let merged-titles = locale-titles + meta.at("section-titles", default: (:))
#if merged-titles.len() > 0 {
  section-args.insert("section-titles", merged-titles)
}

// Document metadata (required for tagged PDF output, e.g. --pdf-standard ua-1)
#set document(title: cd.name, author: cd.name)

#show: cv.with(
  photo: image(photo-file, alt: cd.name, width: 100%, height: 100%, fit: "cover"),
  name: cd.name,
  headline: cd.at("headline", default: none),
  location: cd.at("location", default: none),
  keywords: cd.at("keywords", default: none),
  keywords-lines: if keywords-lines == 0 { auto } else { keywords-lines },
  email: cd.at("email", default: none),
  phone: cd.at("phone", default: none),
  address: cd.at("address", default: none),
  profiles: cd.at("profiles", default: none),
  summary: cd.at("summary", default: none),
  motivation: cd.at("motivation", default: none),
  experience: cd.at("experience", default: none),
  education: cd.at("education", default: none),
  awards: cd.at("awards", default: none),
  volunteering: cd.at("volunteering", default: none),
  courses: cd.at("courses", default: none),
  skills: cd.at("skills", default: none),
  values: cd.at("values", default: none),
  hobbies: cd.at("hobbies", default: none),
  references: cd.at("references", default: none),
  publications: cd.at("publications", default: none),
  show-header-band: header-band,
  header-band-summary: header-band-summary,
  header-band-contact: header-band-contact,
  ats-split: ats-split,
  entry-inline-meta: entry-inline-meta,
  ..locale-args,
  ..section-args,
  // Reorder/move sections, retitle or re-icon them from the meta block:
  //   sidebar-sections / main-sections / section-titles / section-icons
)
