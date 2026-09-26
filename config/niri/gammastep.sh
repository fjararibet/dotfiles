#!/usr/bin/env bash
set -euo pipefail

# gammastep compensates huala's monitor; skip it on every other host.
[ "$(hostname)" = "huala" ] || exit 0

exec gammastep -m wayland -t 6500:6500 -g 0.7 -l 0:0