#!/usr/bin/env sh
set -eu
tests_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
lua "$tests_dir/starter_items_test.lua"
