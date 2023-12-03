#!/bin/bash

set -eux

REQUIRED_VERSION=$(
  cat files/terraform/version.tf |
  hcledit attribute get terraform.required_version
)

REQUIRED_PROVIDERS=$(
  find accounts -name .terraform.lock.hcl |
  xargs -I{} hcl2json {} |
  jq -c '
    .provider |
    to_entries |
    .[] |
    {
      name: (.key | capture("^.+/(?<name>.+)$") | .name),
      source: (.key | capture("^registry\\.terraform\\.io/(?<source>.+)$") | .source),
      version: .value[0].version
    }
  ' |
  jq -s -r '
    group_by(.source) |
    .[] |
    sort_by(.version | split(".") | map(tonumber)) |
    .[-1] |
    [
      .name + " = {",
      "source = \"" + .source + "\"",
      "version = \"" + .version + "\"",
      "}"
    ] |
    join("\n")
  '
)

cat << EOF > files/terraform/version.tf
terraform {
  required_version = ${REQUIRED_VERSION}
  required_providers {
    ${REQUIRED_PROVIDERS}
  }
}
EOF

hcledit fmt -u -f files/terraform/version.tf
