ssh-keygen -t rsa -f krnet2015
nova keypair-delete krnet2015
nova keypair-add --pub_key krnet2015.pub krnet2015
nova keypair-show krnet2015
