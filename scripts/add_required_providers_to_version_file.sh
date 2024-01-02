#!/bin/bash

set -eu

root_modules_top_dir=$1
template_version_tf_path=$2

required_version=$(
  cat ${template_version_tf_path} \
    | hcledit attribute get terraform.required_version
)

required_providers=$(
  find ${root_modules_top_dir} -name .terraform.lock.hcl \
    | xargs -I{} hcl2json {} \
    | jq -c '
        .provider
          | to_entries
          | .[]
          | {
              name: (.key | capture("^.+/(?<name>.+)$") | .name),
              source: (.key | capture("^registry\\.terraform\\.io/(?<source>.+)$") | .source),
              version: .value[0].version
            }
      ' \
    | jq -s -r '
        group_by(.source)
          | .[]
          | sort_by(.version | split(".") | map(tonumber))
          | .[-1]
          | [
              .name + " = {",
              "source = \"" + .source + "\"",
              "version = \"" + .version + "\"",
              "}"
            ]
          | join("\n")
      '
)

cat << EOF > ${template_version_tf_path}
terraform {
  required_version = ${required_version}
  required_providers {
    ${required_providers}
  }
}
EOF

hcledit fmt -u -f ${template_version_tf_path}
