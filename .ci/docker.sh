#!/bin/bash

az acr build \
   --registry {{ .registry_name }} \
   --image {{ .container_repository }}:{{ .container_image_tag }} \
   --platform linux \
   --resource-group {{ .registry_rg }} \
   .