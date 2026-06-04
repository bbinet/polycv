_default:
    @just --list --unsorted

# regenerate schema/schema.json from schema/schema.cue
schema:
    @just -f schema/justfile json

# generate combined thumbnail strip from application.typ
thumbs: link
    @typst compile template/application.typ "thumbnail{p}.png" --ppi 150
    @cp thumbnail1.png thumbnail.png
    @magick thumbnail1.png thumbnail2.png thumbnail3.png +append thumbnail-all.png
    @rm thumbnail1.png thumbnail2.png thumbnail3.png

# compile cv with ATS-friendly header band (visible beige band)
cv-ats: link && unlink
    @mkdir -p out
    @typst compile template/cv.typ out/cv-ats.pdf --input header-band=true

# compile cv with ATS-friendly split layout (invisible, photo|name then skills|summary)
cv-ats-split: link && unlink
    @mkdir -p out
    @typst compile template/cv.typ out/cv-ats-split.pdf --input ats-split=true

# watch cv.typ for changes
watch: link
    typst watch template/cv.typ template/cv.pdf

# remove build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    @find . -name "*.pdf" -not -path "./.git/*" -delete
    @rm -rf out/
    @echo "✅ Done"

# spell check template data files and readme
spell:
    @cspell template/cv.toml template/letter.toml template/cv.yml template/letter.yml README.md --config cspell.toml

# compile all templates as a smoke test (yaml default + toml variant)
build: link && unlink
    @echo "🏗️  Building templates..."
    @mkdir -p out
    @typst compile template/cv.typ out/cv.pdf
    @typst compile template/letter.typ out/letter.pdf
    @typst compile template/application.typ out/application.pdf
    @typst compile template/cv.typ out/cv-toml.pdf --input fmt=toml
    @typst compile template/letter.typ out/letter-toml.pdf --input fmt=toml
    @typst compile template/cv.typ out/cv-ats-split.pdf --input ats-split=true

# symlink the library into the local preview package directory
link:
    #!/usr/bin/env bash
    VERSION=$(grep '^version' typst.toml | sed 's/version = "\(.*\)"/\1/')
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DATA="$HOME/Library/Application Support"
    else
        DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
    fi
    TARGET="$DATA/typst/packages/preview/nabcv/$VERSION"
    mkdir -p "$(dirname "$TARGET")"
    ln -sfn "$(pwd)" "$TARGET"
    echo "linked to $TARGET"

# unlink the library from the local preview package directory
unlink:
    #!/usr/bin/env bash
    VERSION=$(grep '^version' typst.toml | sed 's/version = "\(.*\)"/\1/')
    if [[ "$OSTYPE" == "darwin"* ]]; then
        DATA="$HOME/Library/Application Support"
    else
        DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
    fi
    TARGET="$DATA/typst/packages/preview/nabcv/$VERSION"
    rm -rf "$TARGET"
    echo "unlinked $TARGET"

# Sync dependencies to latest versions
sync:
    @echo "🔄 Syncing dependencies..."
    @utpm ws sync
    @echo "✅ Dependencies synced!"

# bump version (major|minor|patch) without pushing
bump type:
    bump-my-version bump {{ type }}

# bump version (major|minor|patch), commit, tag, and push
release type: (bump type)
    git push
    git push --tags

# verify yaml and toml produce pixel-identical rendered output
test-yaml: link
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p out
    echo "Compiling YAML variant..."
    typst compile --root . template/cv.typ "out/test-yaml{p}.png" --ppi 150
    echo "Compiling TOML variant..."
    typst compile --root . template/cv.typ "out/test-toml{p}.png" --ppi 150 --input fmt=toml
    echo "Comparing pages..."
    for f in out/test-yaml*.png; do
        toml_f="${f/test-yaml/test-toml}"
        if ! magick compare -metric AE "$f" "$toml_f" null: 2>/dev/null; then
            echo "FAIL: $f != $toml_f"
            exit 1
        fi
    done
    echo "OK: YAML and TOML outputs are pixel-identical"
    rm -f out/test-yaml*.png out/test-toml*.png

prek:
    prek run --all-files

prek-ci:
    prek run --all-files --skip schema --skip typstyle --show-diff-on-failure --color always

# run ci suite
ci: prek spell build test-yaml clean
