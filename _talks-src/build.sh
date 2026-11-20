#!/usr/bin/env bash
# Render talk decks in _talks-src/<name>/<name>.qmd to self-contained HTML
# in talks/<name>.html. The website itself only serves the static output.
#
# Usage: _talks-src/build.sh            # all decks
#        _talks-src/build.sh wisar6     # one deck
set -euo pipefail

src_dir="$(cd "$(dirname "$0")" && pwd)"
out_dir="$src_dir/../talks"
mkdir -p "$out_dir"

decks=("$@")
if [ ${#decks[@]} -eq 0 ]; then
  for d in "$src_dir"/*/; do decks+=("$(basename "$d")"); done
fi

for name in "${decks[@]}"; do
  echo "==> $name"
  (
    cd "$src_dir/$name"
    # optional per-deck data prep (e.g. trimming data for embedding)
    if [ -f prep_ojs_data.R ]; then Rscript prep_ojs_data.R; fi
    quarto render "$name.qmd"
  )
  cp "$src_dir/$name/$name.html" "$out_dir/$name.html"
done
