#!/usr/bin/env bash
set -euo pipefail

WAYBAR_CFG="/home/fjara/.config/niri/waybar.jsonc"

# Reload niri config live.
niri msg action load-config-file

# Restart the launcher backends.
systemctl --user restart elephant.service
systemctl --user restart walker.service

# Restart the bar (spawned at startup, so kill and relaunch it).
# The binaries are Nix-wrapped, so match the full command line, not -x.
pkill -f "waybar -c" || true
nohup waybar -c "$WAYBAR_CFG" >/dev/null 2>&1 &

# Reload wallpaper and redshift.
pkill -f "swaybg -i" || true
pkill -f "gammastep -m" || true
nohup swaybg -i /home/fjara/dotfiles/wallpapers/city_night.jpg -m fill >/dev/null 2>&1 &
nohup gammastep -m wayland -t 6500:6500 -g 0.7 -l 0:0 >/dev/null 2>&1 &
