resource "null_resource" "a" {
}

resource "null_resource" "a" {
}

data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}
