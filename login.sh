#!/usr/bin/env bash

readonly old_SHELL="${SHELL}"
readonly old_XDG_DATA_DIRS="${XDG_DATA_DIRS}"

FLAKE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source <(nix --experimental-features "nix-command flakes" print-dev-env "${FLAKE_DIR}")

SHELL="${old_SHELL}"
XDG_DATA_DIRS="${XDG_DATA_DIRS}:${old_XDG_DATA_DIRS}"
