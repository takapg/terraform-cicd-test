setup_each_tmpdir() {
  export EACH_TMPDIR="${SHELLSPEC_PROJECT_ROOT}/spec/tmp/${SHELLSPEC_SPEC_NO}/${SHELLSPEC_EXAMPLE_ID}"
  mkdir -p ${EACH_TMPDIR}
  cd ${EACH_TMPDIR}
}

cleanup_each_tmpdir() {
  rm -rf ${EACH_TMPDIR}
}

cleanup() {
  rm -rf "${SHELLSPEC_PROJECT_ROOT}/spec/tmp"
}

BeforeEach 'setup_each_tmpdir'
AfterEach 'cleanup_each_tmpdir'
AfterAll 'cleanup'

export PATH="${SHELLSPEC_PROJECT_ROOT}/scripts:${PATH}"

Describe 'aaa'
  It 'should be success'
    When call echo 'aaa'
    The output should equal 'aaa'
  End
End

Describe 'generate_dot_terraform_version_files.sh'
  It 'should be success'
    fixture_version_tf_contents=$(
      %text
      #|terraform {
      #|  required_version = "1.0.0"
      #|}
    )

    mkdir -p ./top/target_01
    mkdir -p ./top/target_02
    mkdir -p ./top/not_target_01

    echo "${fixture_version_tf_contents}" > ./top/target_01/version.tf
    echo "${fixture_version_tf_contents}" > ./top/target_02/version.tf

    expected_dot_terraform_version_contents=$(
      %text
      #|1.0.0
    )

    When run script generate_dot_terraform_version_files.sh ./top
    The contents of file ./top/target_01/.terraform-version should equal "${expected_dot_terraform_version_contents}"
    The contents of file ./top/target_02/.terraform-version should equal "${expected_dot_terraform_version_contents}"
    The path ./top/not_target_01/.terraform-version should not be exist
  End
End

Describe 'add_required_providers_to_template_version_tf_file.sh'
  It 'should be success'
    mkdir ./files

    echo "$(
      %text
      #|terraform {
      #|  required_version = "1.0.0"
      #|}
    )" > ./files/version.tf

    mkdir -p ./top/a
    mkdir -p ./top/c_and_b

    echo "$(
      %text
      #|# This file is maintained automatically by "terraform init".
      #|# Manual edits may be lost in future updates.
      #|
      #|provider "registry.terraform.io/hashicorp/a" {
      #|  version     = "1.1.0"
      #|  constraints = "1.1.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
    )" > ./top/a/.terraform.lock.hcl

    echo "$(
      %text
      #|# This file is maintained automatically by "terraform init".
      #|# Manual edits may be lost in future updates.
      #|
      #|provider "registry.terraform.io/hashicorp/c" {
      #|  version     = "1.3.0"
      #|  constraints = "1.3.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
      #|
      #|provider "registry.terraform.io/hashicorp/b" {
      #|  version     = "1.2.0"
      #|  constraints = "1.2.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
    )" > ./top/c_and_b/.terraform.lock.hcl

    expected_template_version_tf_contents=$(
      %text
      #|terraform {
      #|  required_version = "1.0.0"
      #|  required_providers {
      #|    a = {
      #|      source  = "hashicorp/a"
      #|      version = "1.1.0"
      #|    }
      #|    b = {
      #|      source  = "hashicorp/b"
      #|      version = "1.2.0"
      #|    }
      #|    c = {
      #|      source  = "hashicorp/c"
      #|      version = "1.3.0"
      #|    }
      #|  }
      #|}
    )

    When run script add_required_providers_to_template_version_tf_file.sh ./top ./files/version.tf
    The contents of file ./files/version.tf should equal "${expected_template_version_tf_contents}"
  End
End

Describe 'update_dependency_lock_files.sh'
  It 'should be success'
    fixture_version_tf_contents=$(
      %text
      #|terraform {
      #|  required_version = "1.0.0"
      #|  required_providers {
      #|    null = {
      #|      source  = "hashicorp/null"
      #|      version = "3.2.2"
      #|    }
      #|    tls = {
      #|      source  = "hashicorp/tls"
      #|      version = "4.0.5"
      #|    }
      #|  }
      #|}
    )

    mkdir -p ./top/target_01
    mkdir -p ./top/target_02
    mkdir -p ./top/not_target_01

    echo "${fixture_version_tf_contents}" > ./top/target_01/version.tf
    echo "${fixture_version_tf_contents}" > ./top/target_02/version.tf

    expected_dot_terraform_lock_hcl_contents=$(
      %text
      #|# This file is maintained automatically by "terraform init".
      #|# Manual edits may be lost in future updates.
      #|
      #|provider "registry.terraform.io/hashicorp/c" {
      #|  version     = "1.3.0"
      #|  constraints = "1.3.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
      #|
      #|provider "registry.terraform.io/hashicorp/b" {
      #|  version     = "1.2.0"
      #|  constraints = "1.2.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
    )

    When run script update_dependency_lock_files.sh ./top
    The contents of file ./top/target_01/.terraform.lock.hcl should equal "${expected_dot_terraform_lock_hcl_contents}"
    The contents of file ./top/target_02/.terraform.lock.hcl should equal "${expected_dot_terraform_lock_hcl_contents}"
    The path ./top/not_target_01/.terraform.lock.hcl should not be exist
  End
End
