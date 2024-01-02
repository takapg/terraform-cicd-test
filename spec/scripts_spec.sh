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
    When call echo ${version_tf}
    The output should equal 'aaa'
  End
End
