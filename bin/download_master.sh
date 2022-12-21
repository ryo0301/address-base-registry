#!/bin/bash

set -eo pipefail

DIR_ROOT="$(cd $(dirname $0)/..; pwd)"
DIR_DOWNLOAD="${1:-$DIR_ROOT/download}"
API_DOMAIN="registry-catalog.registries.digital.go.jp"
API_RESOURCE_SEARCH="api/action/resource_search"

function search_resource {
  curl -s "https://$API_DOMAIN/$API_RESOURCE_SEARCH?query=$1" | \
  jq -r '.result.results[]|[.name,.url]|join(" ")' | \
  grep -v metadata | sort
}

function download {
  curl -s "$2" \
       -o "$DIR_DOWNLOAD/${1##*/}" \
       -w "${1##*/} %{http_code} %{time_starttransfer} %{size_download}\n" | \
  column -t
}

export DIR_DOWNLOAD
export -f download

mkdir -p "$DIR_DOWNLOAD"

{
  search_resource "name:mt_pref_all"                 # 都道府県マスター
  search_resource "name:mt_city_all"                 # 市区町村マスター
  search_resource "name:mt_town_all"                 # 町字マスター
  search_resource "name:mt_town_pos_pref"            # 町字マスター - 位置参照拡張
  search_resource "name:mt_rsdtdsp_blk_pref"         # 住居表示 - 街区マスター
  search_resource "name:mt_rsdtdsp_blk_pos_pref"     # 住居表示 - 街区マスター位置参照拡張
  search_resource "name:mt_rsdtdsp_rsdt_pref"        # 住居表示 - 住居マスター
  search_resource "name:mt_rsdtdsp_rsdt_pos_pref"    # 住居表示 - 住居マスター位置参照拡張
} | xargs -r -P30 -L1 bash -c 'download $0 $1'
