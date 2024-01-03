#!/bin/bash

set -eu

root_modules_top_dir=$1

find ${root_modules_top_dir} -name .terraform.lock.hcl |
xargs -I{} bash -c 'awk "/^#/" {} > {}_tmp && mv {}_tmp {}'

tfupdate lock \
  --platform=linux_amd64 --platform=linux_arm64 --platform=darwin_amd64 --platform=darwin_arm64 \
  --recursive \
  ${root_modules_top_dir}
