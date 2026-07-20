#!/usr/bin/env bash
# scad-to-3mf.sh — Batch convert .scad files to .3mf using OpenSCAD
# Usage: ./scad-to-3mf.sh [directory]
#        Defaults to the current directory.

set -euo pipefail

OPENSCAD="/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD"
TARGET_DIR="${1:-.}"

if [[ ! -x "$OPENSCAD" ]]; then
  echo "Error: OpenSCAD not found at $OPENSCAD" >&2
  exit 1
fi

shopt -s nullglob
scad_files=("$TARGET_DIR"/*.scad)

if [[ ${#scad_files[@]} -eq 0 ]]; then
  echo "No .scad files found in $TARGET_DIR"
  exit 0
fi

echo "Converting ${#scad_files[@]} file(s) in $TARGET_DIR"
echo "---"

ok=0
fail=0

for scad in "${scad_files[@]}"; do
  name="$(basename "$scad" .scad)"
  output="$TARGET_DIR/${name}.3mf"

  if "$OPENSCAD" -o "$output" "$scad"; then
    echo "  ✓ $name.scad → $name.3mf"
    ((ok++))
  else
    echo "  ✗ $name.scad — conversion failed" >&2
    ((fail++))
  fi
done

echo "---"
echo "Done. $ok succeeded, $fail failed."
