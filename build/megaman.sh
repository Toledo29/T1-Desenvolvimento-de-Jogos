#!/bin/sh
printf '\033c\033]0;%s\a' Megaman (NES)
base_path="$(dirname "$(realpath "$0")")"
"$base_path/megaman.x86_64" "$@"
