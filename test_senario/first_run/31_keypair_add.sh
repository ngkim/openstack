ssh-keygen -t rsa -f spirent
nova keypair-delete spirent
nova keypair-add --pub_key spirent.pub spirent
nova keypair-show spirent
