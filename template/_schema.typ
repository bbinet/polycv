// Internal helper for `make validate` - not part of your documents.
// Loads a data file, resolves any `inherit:` chain, and exposes the merged
// document as metadata so the Makefile can pull it out as JSON:
//   typst eval 'query(<polycv-data>).first().value' --in _schema.typ \
//     --input data=<file> --input fmt=<yaml|toml> --format json
// It mirrors the loading in cv.typ / letter.typ but does no layout, so it
// never fails on data that merely violates the schema.
#let fmt = sys.inputs.at("fmt", default: "yaml")
#let data-file = sys.inputs.at("data")
#let load-data(f) = if fmt == "yaml" { yaml(f) } else { toml(f) }

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

#metadata(load-inherited(data-file)) <polycv-data>
