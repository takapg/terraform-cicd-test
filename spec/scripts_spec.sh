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

    fixture_dot_terraform_lock_hcl_contents=$(
      %text
      #|# This file is maintained automatically by "terraform init".
      #|# Manual edits may be lost in future updates.
      #|
      #|provider "registry.terraform.io/hashicorp/dummy" {
      #|  version     = "1.1.0"
      #|  constraints = "1.1.0"
      #|  hashes = [
      #|    "h1:dummy",
      #|    "zh:dummy",
      #|  ]
      #|}
    )

    mkdir -p ./top/target_01
    mkdir -p ./top/target_02
    mkdir -p ./top/not_target_01

    echo "${fixture_version_tf_contents}" > ./top/target_01/version.tf
    echo "${fixture_version_tf_contents}" > ./top/target_02/version.tf

    echo "${fixture_dot_terraform_lock_hcl_contents}" > ./top/target_01/.terraform.lock.hcl
    echo "${fixture_dot_terraform_lock_hcl_contents}" > ./top/target_02/.terraform.lock.hcl

    expected_dot_terraform_lock_hcl_contents=$(
      %text
      #|# This file is maintained automatically by "terraform init".
      #|# Manual edits may be lost in future updates.
      #|
      #|provider "registry.terraform.io/hashicorp/null" {
      #|  version     = "3.2.2"
      #|  constraints = "3.2.2"
      #|  hashes = [
      #|    "h1:Gef5VGfobY5uokA5nV/zFvWeMNR2Pmq79DH94QnNZPM=",
      #|    "h1:IMVAUHKoydFrlPrl9OzasDnw/8ntZFerCC9iXw1rXQY=",
      #|    "h1:vWAsYRd7MjYr3adj8BVKRohVfHpWQdvkIwUQ2Jf5FVM=",
      #|    "h1:zT1ZbegaAYHwQa+QwIFugArWikRJI9dqohj8xb0GY88=",
      #|    "zh:3248aae6a2198f3ec8394218d05bd5e42be59f43a3a7c0b71c66ec0df08b69e7",
      #|    "zh:32b1aaa1c3013d33c245493f4a65465eab9436b454d250102729321a44c8ab9a",
      #|    "zh:38eff7e470acb48f66380a73a5c7cdd76cc9b9c9ba9a7249c7991488abe22fe3",
      #|    "zh:4c2f1faee67af104f5f9e711c4574ff4d298afaa8a420680b0cb55d7bbc65606",
      #|    "zh:544b33b757c0b954dbb87db83a5ad921edd61f02f1dc86c6186a5ea86465b546",
      #|    "zh:696cf785090e1e8cf1587499516b0494f47413b43cb99877ad97f5d0de3dc539",
      #|    "zh:6e301f34757b5d265ae44467d95306d61bef5e41930be1365f5a8dcf80f59452",
      #|    "zh:78d5eefdd9e494defcb3c68d282b8f96630502cac21d1ea161f53cfe9bb483b3",
      #|    "zh:913a929070c819e59e94bb37a2a253c228f83921136ff4a7aa1a178c7cce5422",
      #|    "zh:aa9015926cd152425dbf86d1abdbc74bfe0e1ba3d26b3db35051d7b9ca9f72ae",
      #|    "zh:bb04798b016e1e1d49bcc76d62c53b56c88c63d6f2dfe38821afef17c416a0e1",
      #|    "zh:c23084e1b23577de22603cff752e59128d83cfecc2e6819edadd8cf7a10af11e",
      #|  ]
      #|}
      #|
      #|provider "registry.terraform.io/hashicorp/tls" {
      #|  version     = "4.0.5"
      #|  constraints = "4.0.5"
      #|  hashes = [
      #|    "h1:e4LBdJoZJNOQXPWgOAG0UuPBVhCStu98PieNlqJTmeU=",
      #|    "h1:kcw9sNLNFMY2S0HIGOkjlwKtUc8lpqZsQGsC2SG9xEQ=",
      #|    "h1:yLqz+skP3+EbU3yyvw8JqzflQTKDQGsC9QyZAg+S4dg=",
      #|    "h1:zeG5RmggBZW/8JWIVrdaeSJa0OG62uFX5HY1eE8SjzY=",
      #|    "zh:01cfb11cb74654c003f6d4e32bbef8f5969ee2856394a96d127da4949c65153e",
      #|    "zh:0472ea1574026aa1e8ca82bb6df2c40cd0478e9336b7a8a64e652119a2fa4f32",
      #|    "zh:1a8ddba2b1550c5d02003ea5d6cdda2eef6870ece86c5619f33edd699c9dc14b",
      #|    "zh:1e3bb505c000adb12cdf60af5b08f0ed68bc3955b0d4d4a126db5ca4d429eb4a",
      #|    "zh:6636401b2463c25e03e68a6b786acf91a311c78444b1dc4f97c539f9f78de22a",
      #|    "zh:76858f9d8b460e7b2a338c477671d07286b0d287fd2d2e3214030ae8f61dd56e",
      #|    "zh:a13b69fb43cb8746793b3069c4d897bb18f454290b496f19d03c3387d1c9a2dc",
      #|    "zh:a90ca81bb9bb509063b736842250ecff0f886a91baae8de65c8430168001dad9",
      #|    "zh:c4de401395936e41234f1956ebadbd2ed9f414e6908f27d578614aaa529870d4",
      #|    "zh:c657e121af8fde19964482997f0de2d5173217274f6997e16389e7707ed8ece8",
      #|    "zh:d68b07a67fbd604c38ec9733069fbf23441436fecf554de6c75c032f82e1ef19",
      #|    "zh:f569b65999264a9416862bca5cd2a6177d94ccb0424f3a4ef424428912b9cb3c",
      #|  ]
      #|}
    )

    When run script update_dependency_lock_files.sh ./top
    The contents of file ./top/target_01/.terraform.lock.hcl should equal "${expected_dot_terraform_lock_hcl_contents}"
    The contents of file ./top/target_02/.terraform.lock.hcl should equal "${expected_dot_terraform_lock_hcl_contents}"
    The path ./top/not_target_01/.terraform.lock.hcl should not be exist
  End
End
