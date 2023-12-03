#!/bin/bash

set -eux

generate_terraform_version() {
  working_dir=$1
  hcledit --file ${working_dir} attribute get terraform.required_version |
  tr -d '"' > $(dirname ${working_dir})/.terraform-version
}
export -f generate_terraform_version

find accounts -name version.tf |
xargs -I{} bash -c 'generate_terraform_version {}'
