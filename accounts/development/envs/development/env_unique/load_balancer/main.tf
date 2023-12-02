resource "null_resource" "a" {
}

resource "local_file" "a" {
  filename = "/tmp/foo.bar"
}
