setup_each_tmpdir() {
  EACH_TMPDIR="${SHELLSPEC_WORKDIR}/${SHELLSPEC_EXAMPLE_ID}"
  mkdir -p ${EACH_TMPDIR}
  cd ${EACH_TMPDIR}
}

BeforeEach 'setup_each_tmpdir'

export PATH="$PATH:./scripts"

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

    When call generate_terraform_version_files.sh ${EACH_TMPDIR}
    The contents of file ./target_01/.terraform-version should equal "${dot_terraform_version}"
    The contents of file ./target_02/.terraform-version should equal "${dot_terraform_version}"
    The path ./not_target_01/.terraform-version should not be exist
  End
End
