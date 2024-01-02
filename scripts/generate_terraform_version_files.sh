#!/bin/bash

set -eu

root_modules_top_dir=$1

generate_dot_terraform_version_file() {
  version_tf_path=$1
  hcledit --file ${version_tf_path} attribute get terraform.required_version \
    | tr -d '"' > $(dirname ${version_tf_path})/.terraform-version
}
export -f generate_dot_terraform_version_file

find ${root_modules_top_dir} -name version.tf \
  | xargs -I{} bash -c 'generate_dot_terraform_version_file {}'
