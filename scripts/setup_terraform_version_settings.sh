#!/bin/bash

set -eu

root_modules_top_dir=$1
template_version_tf_path=$2

./scripts/generate_dot_terraform_version_files.sh ${root_modules_top_dir}
./scripts/add_required_providers_to_template_version_tf_file.sh ${root_modules_top_dir} ${template_version_tf_path}

git diff --exit-code ${template_version_tf_path} \
  || (cd ${root_modules_top_dir} && terragrunt run-all init -upgrade)

./scripts/update_dependency_lock_files.sh ${root_modules_top_dir}
