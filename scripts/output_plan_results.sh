#!/bin/bash

set -eu

tmp_tf_log_file_name='tmp_terraform.log'
tmp_tfcmt_result_file_name='tmp_tfcmt_result.md'
plan_results_file_name='plan_results.md'

plan_actions_regex_pattern='^Plan: [0-9]+ to add,.+to destroy\.$'

diff_results=''
no_diff_results=''

result_header='
  <tr>
    <th>directory</th>
    <th>plan detail</th>
  </tr>
'

rm_tmp_files() {
  for tmp_tf_log_file_path in $(find . ${tmp_tf_log_file_name} | sort); do
    rm -v ${tmp_tf_log_file_path}
  done

  for tmp_tfcmt_result_file_path in $(find . ${tmp_tfcmt_result_file_name} | sort); do
    rm -v ${tmp_tfcmt_result_file_path}
  done
}

rm_tmp_files

terragrunt run-all plan --terragrunt-tfpath $(git rev-parse --show-toplevel)/scripts/terraform_with_output_log_file.sh
