#!/bin/bash

image_name=$1
image_file=$2


ing() {

    echo "# ---------------------------------------------------------------------"
    echo " glance image create image_name[$image_name]<-image_file[$image_file] !!!"
    echo "# ---------------------------------------------------------------------"
    
}

usage() {

    echo "
    # ---------------------------------------------------------------------
    usage:: image_upload.sh image_name image_file
    ex) image_upload.sh ubuntu-12.04 ubuntu-12.04.img
    # ---------------------------------------------------------------------
    "
}
    
if [ $image_name ] && [ $image_file ]
then
    ing 
else
    usage
    exit
fi


image_id=$(glance image-list | grep "$image_name " | awk '{print $2}')

if [ $image_id ]; then
    echo "# ----------------------------------------------------------------"
    echo "image[${image_name}] already exists"    
    echo "# ----------------------------------------------------------------"
    exit
else
    echo ""
fi

if [ -f $image_file ]; then
    echo ""
else
    echo "# ----------------------------------------------------------------"
    echo "image_file[${image_file}] does not exist on this host !!!"    
    echo "# ----------------------------------------------------------------"
    exit
fi

# sample:
# glance image-create --name="ubuntu-12.04" --disk-format=qcow2 --container-format=bare \
#    --is-public=true --file ~/images/ubuntu-12.04.qcow --progress --human-readable

echo "glance image-create --name=$image_name --disk-format=qcow2 --container-format=bare --is-public=true --file $image_file --progress"
glance image-create --name=$image_name --disk-format=qcow2 --container-format=bare \
    --is-public=true --file $image_file --progress