#!/usr/bin/env bash
set -euo pipefail

fail() {
    notify-send --urgency=critical "Display mode" "$1"
    exit 1
}

selection=$(printf '%s\n' "Laptop only" "External only" "Extend" |
    walker --dmenu --placeholder "Display mode") || exit 0
[[ -n "$selection" ]] || exit 0

outputs=$(niri msg --json outputs)
mapfile -t internal < <(jq -r '.[] | select(.modes | length > 0) | .name | select(test("^(eDP|LVDS|DSI)-"))' <<< "$outputs")
mapfile -t external < <(jq -r '.[] | select(.modes | length > 0) | .name | select(test("^(eDP|LVDS|DSI)-") | not)' <<< "$outputs")

case "$selection" in
    "Laptop only")
        ((${#internal[@]} > 0)) || fail "No built-in display detected."
        enabled=("${internal[@]}")
        disabled=("${external[@]}")
        ;;
    "External only")
        ((${#external[@]} > 0)) || fail "No external monitor detected; leaving displays unchanged."
        enabled=("${external[@]}")
        disabled=("${internal[@]}")
        ;;
    "Extend")
        enabled=("${internal[@]}" "${external[@]}")
        disabled=()
        ;;
    *) exit 0 ;;
esac

((${#enabled[@]} > 0)) || fail "No connected displays detected."
for output in "${enabled[@]}"; do
    niri msg output "$output" on
    niri msg output "$output" position auto
done

# Re-query after enabling: never disable the old screen unless its replacement
# is active. This also catches a monitor unplugged while the menu was open.
outputs=$(niri msg --json outputs)
for output in "${enabled[@]}"; do
    jq -e --arg output "$output" '.[$output] | .current_mode != null and .logical != null' \
        <<< "$outputs" > /dev/null || fail "Could not activate $output; leaving other displays on."
done
for output in "${disabled[@]}"; do
    niri msg output "$output" off
done

notify-send "Display mode" "$selection"
