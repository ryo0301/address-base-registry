#!/bin/bash

set -eo pipefail

DIR_ROOT="$(cd $(dirname $0)/..; pwd)"
DIR_DOWNLOAD="${1:-$DIR_ROOT/download}"
DIR_EXTRACT="${2:-$DIR_ROOT/extract}"

mkdir -p "$DIR_EXTRACT"

for zip in "$DIR_DOWNLOAD/*.zip"; do
  unzip "$zip" -d "$DIR_EXTRACT"
done
