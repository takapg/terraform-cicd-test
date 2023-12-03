#!/bin/bash

set -eux

find accounts -name .terraform.lock.hcl |
xargs -I{} awk -i inplace '/^#/' {}

tfupdate lock \
  --platform=linux_amd64 --platform=linux_arm64 --platform=darwin_amd64 --platform=darwin_arm64 \
  --recursive \
  accounts
