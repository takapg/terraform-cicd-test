#!/bin/bash

git diff --exit-code \
  || (cd accounts && terragrunt run-all init -upgrade)

set -eux

find accounts -name .terraform.lock.hcl |
xargs -I{} bash -c 'awk "/^#/" {} > {}_tmp && mv {}_tmp {}'

tfupdate lock \
  --platform=linux_amd64 --platform=linux_arm64 --platform=darwin_amd64 --platform=darwin_arm64 \
  --recursive \
  accounts
