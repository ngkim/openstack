ACCESS_KEY=adminkey
PUB_KEY="${ACCESS_KEY}.pub"

ssh-keygen -t rsa -f $ACCESS_KEY
nova keypair-delete $ACCESS_KEY
nova keypair-add --pub_key $PUB_KEY $ACCESS_KEY
nova keypair-show $ACCESS_KEY
