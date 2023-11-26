include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "network" {
  config_path = "../network"

  skip_outputs = true
}
