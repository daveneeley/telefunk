#!/bin/bash

terraform fmt -check

terraform init

terraform validate -no-color

terraform plan