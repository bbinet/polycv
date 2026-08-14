// typst compile --root . template/letter.typ
#import "@preview/polycv:0.1.1": letter

#let fmt = sys.inputs.at("fmt", default: "yaml")
#let data-file = sys.inputs.at("data", default: if fmt == "toml" { "letter.toml" } else { "letter.yml" })
#let load-data(f) = if fmt == "yaml" { yaml(f) } else { toml(f) }

// Recursively merge a child over its parent: dicts merge key by key, arrays
// merge by index, other values are replaced. `none` keeps the parent value.
#let deep-merge(base, over) = {
  if over == none {
    base
  } else if type(base) == dictionary and type(over) == dictionary {
    let out = base
    for (k, v) in over { out.insert(k, deep-merge(base.at(k, default: none), v)) }
    out
  } else if type(base) == array and type(over) == array {
    range(calc.max(base.len(), over.len())).map(i => deep-merge(
      base.at(i, default: none),
      over.at(i, default: none),
    ))
  } else { over }
}

#let dir-of(f) = {
  let parts = f.split("/")
  if parts.len() <= 1 { "" } else { parts.slice(0, -1).join("/") + "/" }
}

// Resolve `inherit: <path>` chains (path relative to the file): deep-merge
// this file over its recursively-resolved parent.
#let load-inherited(f) = {
  let raw = load-data(f)
  let parent = raw.at("inherit", default: none)
  if parent == none {
    raw
  } else {
    let child = raw
    let _ = child.remove("inherit")
    deep-merge(load-inherited(dir-of(f) + parent), child)
  }
}

#let ld = load-inherited(data-file).letter

// Document metadata (required for tagged PDF output, e.g. --pdf-standard ua-1)
#set document(title: ld.sender.name, author: ld.sender.name)

#show: letter.with(
  sender: ld.sender,
  recipient: {
    let r = ld.at("recipient", default: (:))
    if r.at("name", default: "") != "" [*#r.name* \ ]
    if r.at("title", default: "") != "" [#r.title \ ]
    if r.at("company", default: "") != "" [*#r.company* \ ]
    if r.at("address", default: "") != "" [#r.address]
  },
  date: ld.at("metadata", default: (:)).at("date", default: "auto"),
  subject: ld.content.at("subject", default: none),
  salutation: ld.content.at("salutation", default: none),
  closing: ld.content.at("closing", default: [Kind regards]),
)

#for para in ld.content.at("body", default: ()) {
  eval(para.paragraph, mode: "markup")
  v(8pt)
}
