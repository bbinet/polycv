// typst compile --root . docs/docs.typ docs/docs.pdf
#import "@preview/tidy:0.4.2"
#import "./docs-template.typ": template

#let version = toml("/typst.toml").package.version

#show: template.with(
  title: "nabcv",
  subtitle: "not-a-boring CV",
  authors: ("Resul",),
  version: version,
)

== Introduction

nabcv is a data-driven, two-column Typst CV package. All personal data lives in
`.toml` files; the template is a clean, untouched `.typ`. The package exposes
two functions — `cv` and `letter` — described below.

== `cv`

#let cv-docs = tidy.parse-module(read("/src/cv.typ"))
#tidy.show-module(
  cv-docs,
  show-outline: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
)

== `letter`

#let letter-docs = tidy.parse-module(read("/src/letter.typ"))
#tidy.show-module(
  letter-docs,
  show-outline: false,
  omit-private-definitions: true,
  omit-private-parameters: true,
)
