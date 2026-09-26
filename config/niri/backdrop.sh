#!/usr/bin/env bash
set -euo pipefail

# Start the overview backdrop wallpaper daemon if it isn't already running.
pgrep -f "awww-daemon --namespace backdrop" >/dev/null || awww-daemon --namespace backdrop >/dev/null 2>&1 &

# Wait for the daemon to come up, then set the backdrop image.
for _ in $(seq 1 50); do
  if awww img -n backdrop /home/fjara/dotfiles/wallpapers/city_gojo.jpg 2>/dev/null; then
    exit 0
  fi
  sleep 0.1
done
exit 1