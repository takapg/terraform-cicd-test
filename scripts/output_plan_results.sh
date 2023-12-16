#!/bin/bash

set -eu

tmp_tf_log_file_name='tmp_terraform.log'
tmp_tfcmt_result_file_name='tmp_tfcmt_result.md'
plan_results_file_name='plan_results.md'

plan_actions_regex_pattern='^Plan: [0-9]+ to add,.+to destroy\.$'
ci_link_regex_pattern='^\[CI link\].+$'

diff_results=''
no_diff_results=''

result_header='
  <tr>
    <th>directory</th>
    <th>plan detail</th>
  </tr>
'

rm_tmp_files() {
  for tmp_tf_log_file_path in $(find . -name ${tmp_tf_log_file_name} | sort); do
    rm -v ${tmp_tf_log_file_path}
  done

  for tmp_tfcmt_result_file_path in $(find . -name ${tmp_tfcmt_result_file_name} | sort); do
    rm -v ${tmp_tfcmt_result_file_path}
  done
}

rm_tmp_files

terragrunt run-all plan --terragrunt-tfpath $(git rev-parse --show-toplevel)/scripts/terraform_with_output_log_file.sh

for tmp_tf_log_file_path in $(find . -name ${tmp_tf_log_file_name} | sort); do
  root_module_dir=$(dirname ${tmp_tf_log_file_path})
  root_module_dir_to_git_repo_root="$(git rev-parse --show-toplevel)$(echo ${root_module_dir} | sed 's/.\///')"
  tmp_tfcmt_result_file_path="${root_module_dir}/${tmp_tfcmt_result_file_name}"

  echo ''
  echo ''
  echo '###'
  echo "# ${root_module_dir_to_git_repo_root}"
  echo '###'

  tfcmt --output ${tmp_tfcmt_result_file_path} plan -- cat ${tmp_tf_log_file_path}

  result="
  <tr>
    <td>${root_module_dir_to_git_repo_root}</td>
    <td>$(cat ${tmp_tfcmt_result_file_path} | sed 's/## Plan Result//')</td>
  </tr>
  "

  plan_actions_text=$(cat ${tmp_tfcmt_result_file_path} | grep -E "${plan_actions_regex_pattern}" || echo '')

  if [ "${plan_actions_text}" != '' ]; then
    diff_results+="${result}"
  else
    no_diff_results+="${result}"
  fi
done

plan_results=$(cat << EOF
### Diff results

<table>
  ${result_header}
  ${diff_results}
</table>

---

### No diff results

<details><summary>(Click me)</summary>
  <table>
    ${result_header}
    ${no_diff_results}
  </table>
</details>
EOF
)

ci_link=$(echo "${plan_results}" | grep -E "${ci_link_regex_pattern}" | uniq)
plan_results_without_ci_link=$(echo "${plan_results}" | grep -v -E "${ci_link_regex_pattern}")

cat << EOF > ${plan_results_file_name}
${ci_link}

${plan_results_without_ci_link}
EOF

rm_tmp_files
