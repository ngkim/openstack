#!/bin/bash

IMAGELABEL="cirros"
FILEFORMAT="qcow2"
CONTAINERFORMAT="bare"
ACCESSVALUE="True"
IMAGEFILE="cirros-0.3.2-x86_64-disk.img"

echo "glance image-create --name=$IMAGELABEL --disk-format=$FILEFORMAT \
  --container-format=$CONTAINERFORMAT --is-public=$ACCESSVALUE --progress < $IMAGEFILE"

glance image-create --name=$IMAGELABEL --disk-format=$FILEFORMAT \
  --container-format=$CONTAINERFORMAT --is-public=$ACCESSVALUE --progress < $IMAGEFILE
