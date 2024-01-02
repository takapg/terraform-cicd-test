setup() {
  mkdir -p ./spec/tmp
}

cleanup() {
  rm -rf ./spec/tmp
}

BeforeAll 'setup'
AfterAll 'cleanup'

Describe 'aaa'
  It 'should be success'
    When call echo 'aaa'
    The output should equal 'aaa'
  End
End

Describe 'generate_terraform_version_files.sh'
  It 'should be success'
    version_tf=$(
      %text
      #|terraform {
      #|  required_version = "1.0.0"
      #|}
    )

    dot_terraform_version=$(
      %text
      #|1.0.0
    )

    tmp_root_path='./spec/tmp/generate_terraform_version_files'
    mkdir -p "${tmp_root_path}/target_01"
    mkdir -p "${tmp_root_path}/target_02"
    mkdir -p "${tmp_root_path}/not_target_01"

    echo "${version_tf}" > "${tmp_root_path}/target_01/version.tf"
    echo "${version_tf}" > "${tmp_root_path}/target_02/version.tf"

    When call .scripts/generate_terraform_version_files.sh ${tmp_root_path}
    The contents of file "${tmp_root_path}/target_01/.terraform-version" should equal "${dot_terraform_version}"
  End
End
