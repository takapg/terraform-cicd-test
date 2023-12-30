resource "null_resource" "a" {
}

resource "local_file" "foo" {
  content  = "foo!"
  filename = "./foo.bar"
}
