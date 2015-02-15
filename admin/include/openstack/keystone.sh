get_tenant_id() {
	TNAME=$1

	_TID=`keystone tenant-list | grep $TNAME | awk '{print $2}'`
	
	echo $_TID
}

get_user_id() {
	UNAME=$1

	_UID=`keystone user-list | grep $UNAME | awk '{print $2}'`
	
	echo $_UID
}

get_role_id() {
	RNAME=$1

        RID=`keystone role-list | grep $RNAME | awk '{ print $2}'`

	echo $RID	
}

create_tenant() {
	TNAME=$1

	TID=$(get_tenant_id $TNAME)
	if [ -z $TID ]; then
		TID=`keystone tenant-create --name $TNAME | awk '/ id / {print $4}'`
	fi

	echo $TID
}

list_users() {
	keystone user-list
}

create_user_in_tenant() {
	UNAME=$1
	UPASS=$2
	TID=$3
	EMAIL=$4
	
	USER_ID=$(get_user_id $UNAME)
	if [ -z $USER_ID ]; then
		USER_ID=`keystone user-create --name=$UNAME --pass=$UPASS --tenant-id $TID --email=$EMAIL | awk '/ id / {print $4}'`
		RID=$(get_role_id Member)
		echo "keystone user-role-add --tenant-id $TID --user-id $USER_ID --role-id $RID"
		keystone user-role-add --tenant-id $TID --user-id $USER_ID --role-id $RID
	fi
}
