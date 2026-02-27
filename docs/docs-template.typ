#let template(
  title: "",
  subtitle: "",
  authors: (),
  version: "",
  doc,
) = {
  set document(author: authors, title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "IBM Plex Sans", lang: "en")
  show link: set text(fill: rgb("#005F87"))
  show link: underline

  align(center, text(17pt, weight: "bold")[
    #title \
    #text(12pt, weight: "regular")[#subtitle]
  ])

  v(6pt)

  align(center, rect[
    #emph[Authors: #authors.join(", ")] \
    #emph[Version: #version] \
    #emph[Build Date: #datetime.today().display()]
  ])

  outline(depth: 2)

  pagebreak()

  doc
}
