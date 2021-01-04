#!/bin/bash

terraform plan -var name=example-machine -var size=Standard_F2 -var adminuser=tom
