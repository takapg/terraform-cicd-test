#!/bin/bash

terraform $@ 2>&1 | tee -a ./tmp_terraform.log
