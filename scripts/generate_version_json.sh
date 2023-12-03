#!/bin/bash

set -eux

TERRAFORM_REQUIRED_VERSION=$(
  cat files/terraform/version.json |
  jq -r '.terraform[0].required_version'
)

find accounts -name .terraform.lock.hcl |
xargs -I{} hcl2json {} |
jq -c '
  .provider |
  to_entries |
  .[] |
  {
    name: (.key | capture("^.+/(?<name>.+)$") | .name),
    source: .key,
    version: .value[0].version
  }
' |
jq -s -c '
  group_by(.source) |
  .[] |
  sort_by(.version | split(".") | map(tonumber)) |
  .[-1] |
  {
    (.name): {
      source: .source,
      version: .version
    }
  }
' | 
jq -s -r "
  {
    terraform: [
      {
        required_version: \"${TERRAFORM_REQUIRED_VERSION}\",
        required_providers: .
      }
    ]
  }
" > files/terraform/version.json
