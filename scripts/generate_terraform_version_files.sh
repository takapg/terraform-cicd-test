#!/bin/bash

set -eux

generate_terraform_version_file() {
  version_file_path=$1
  hcledit --file ${version_file_path} attribute get terraform.required_version |
  tr -d '"' > $(dirname ${version_file_path})/.terraform-version
}
export -f generate_terraform_version_file

find accounts -name version.tf |
xargs -I{} bash -c 'generate_terraform_version_file {}'
