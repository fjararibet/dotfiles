#!/usr/bin/env bash
set -euo pipefail

# Use a separate namespace for the desktop and overview wallpapers.
namespace="${1:-backdrop}"
image="${2:-/home/fjara/dotfiles/wallpapers/city_gojo.jpg}"

# Start the wallpaper daemon if it is not already running.
pgrep -f "awww-daemon --namespace ${namespace}" >/dev/null || awww-daemon --namespace "$namespace" >/dev/null 2>&1 &

# Wait for the daemon to come up, then set the backdrop image.
for _ in $(seq 1 50); do
  if awww img -n "$namespace" "$image" 2>/dev/null; then
    exit 0
  fi
  sleep 0.1
done
exit 1
