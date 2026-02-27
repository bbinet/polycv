_default:
    @just --list --unsorted

# regenerate schema/schema.json from schema/schema.cue
schema:
    @just -f schema/justfile json

# generate combined thumbnail strip from application.typ
thumbs:
    @typst compile template/application.typ "thumbnail{p}.png" --ppi 150
    @magick thumbnail1.png thumbnail2.png thumbnail3.png +append thumbnail.png
    @rm thumbnail1.png thumbnail2.png thumbnail3.png

# watch cv.typ for changes
watch: link
    typst watch template/cv.typ template/cv.pdf

# remove build artifacts
clean:
    @echo "🧹 Cleaning build artifacts..."
    @find . -name "*.pdf" -not -path "./.git/*" -delete
    @rm -rf out/
    @echo "✅ Done"

# spell check template toml files and readme
spell:
    @cspell template/cv.toml template/letter.toml README.md --config cspell.toml

# compile all templates as a smoke test
build: link && unlink
    @echo "🏗️  Building templates..."
    @mkdir -p out
    @typst compile template/cv.typ out/cv.pdf
    @typst compile template/letter.typ out/letter.pdf
    @typst compile template/application.typ out/application.pdf

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

prek:
    prek run --all-files

# run ci suite
ci: spell build clean
