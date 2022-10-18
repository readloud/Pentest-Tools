#!/bin/bash

import_data_aws () {
  scp -r ~/Desktop/import_data/import_data "${1}:/home/ubuntu"
  echo "Import finished."
}

import_data_aws $1
