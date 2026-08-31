#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="$project_dir/dist"
package_path="$dist_dir/PowerQueryInfluxHomeAssistant.mez"
stage_dir="$(mktemp -d)"
trap 'rm -rf "$stage_dir"' EXIT

mkdir -p "$dist_dir"
rm -f "$package_path"
cp "$project_dir/src/HomeAssistantInflux.pq" "$stage_dir/"
cp "$project_dir"/assets/HomeAssistantInflux*.png "$stage_dir/"
touch -t 198001010000 "$stage_dir"/*
(
  cd "$stage_dir"
  TZ=UTC zip -X -q "$package_path" HomeAssistantInflux.pq HomeAssistantInflux*.png
)

unzip -t "$package_path"
echo "Created $package_path"
