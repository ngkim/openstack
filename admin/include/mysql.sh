create_database() {
	DB_NAME=$1

	if [[ -z $MYSQL_ADMIN || -z $MYSQL_ADMIN_PASS ]]; then
		print_err MYSQL "Needs MYSQL Login information"
	fi
	mysql -u $MYSQL_ADMIN -p$MYSQL_ADMIN_PASS -e "create database $DB_NAME"
}

grant_database_user() {
	DB_NAME=$1
	USER_ID=$2
	USER_PASS=$3

	if [[ -z $MYSQL_ADMIN || -z $MYSQL_ADMIN_PASS ]]; then
		print_err MYSQL "Needs MYSQL Login information"
	fi
	mysql -u $MYSQL_ADMIN -p$MYSQL_ADMIN_PASS -e "GRANT ALL ON $DB_NAME.* TO '$USER_ID'@'localhost' IDENTIFIED BY '$USER_PASS';FLUSH PRIVILEGES;"
	mysql -u $MYSQL_ADMIN -p$MYSQL_ADMIN_PASS -e "GRANT ALL ON $DB_NAME.* TO '$USER_ID'@'%' IDENTIFIED BY '$USER_PASS';FLUSH PRIVILEGES;"
}

dump_remote_database() {
	NODE=$1
	DB_NAME=$2

	if [[ -z $MYSQL_ADMIN || -z $MYSQL_ADMIN_PASS ]]; then
		print_err MYSQL "Needs MYSQL Login information"
	fi

	ssh $NODE "mysqldump -u $MYSQL_ADMIN -p$MYSQL_ADMIN_PASS $DATABASE"
}
