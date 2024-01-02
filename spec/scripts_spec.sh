setup_each_tmpdir() {
  EACH_TMPDIR="./spec/tmp/${SHELLSPEC_SPEC_NO}/${SHELLSPEC_EXAMPLE_ID}"
  mkdir -p ${EACH_TMPDIR}
  cd ${EACH_TMPDIR}
}

cleanup_each_tmpdir() {
  rm -rf ${EACH_TMPDIR}
}

BeforeEach 'setup_each_tmpdir'
AfterEach 'cleanup_each_tmpdir'

export PATH="${SHELLSPEC_PROJECT_ROOT}/scripts:${PATH}"

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

    mkdir ./target_01
    mkdir ./target_02
    mkdir ./not_target_01

    echo "${version_tf}" > ./target_01/version.tf
    echo "${version_tf}" > ./target_02/version.tf

    When call generate_terraform_version_files.sh .
    The contents of file ./target_01/.terraform-version should equal "${dot_terraform_version}"
    The contents of file ./target_02/.terraform-version should equal "${dot_terraform_version}"
    The path ./not_target_01/.terraform-version should not be exist
  End
End
