#!/bin/bash

#-----------------------------------------------------------------------------------------------+
# Namgon Kim (2014.09.13)
#-----------------------------------------------------------------------------------------------+
# 이 스크립트는 keystone endpoint의 public url 정보를 keystone db에 접근해서 update함
# - keystone endpoint 중 public url에는 외부에서 접근 가능한 주소가 입력되어야 함
# - 현재의 keystone command line에는 endpoint update를 위한 명령은 없음
# - admin, internal url에 대해서는 update를 지원하지 않음
#
# 동작확인
# - 새로 생성한 url 정보와 DB에 입력된 url 정보를 비교하여 동일하면 정상처리
#-----------------------------------------------------------------------------------------------+
#
# hash를 이용해서 endpoint url관리
declare -A map_url
map_url["keystone"]="http://%s:5000/v2.0"
map_url["ec2"]="http://%s:8773/services/Cloud"
map_url["glance"]="http://%s:9292/v2"
map_url["cinder"]="http://%s:8776/v1/\%(tenant_id)s"
map_url["cinderv2"]="http://%s:8776/v2/\%(tenant_id)s"
map_url["neutron"]="http://%s:9696"
#map_url["keystone-admin"]="http://%s:35357/v2.0"
#map_url["ec2-admin"]="http://%s:8773/services/Admin"
#
#-----------------------------------------------------------------------------------------------+

usage() {
    echo " >> Description : keystone DB를 수정해 외부에서 접근 가능한 주소를 변경"
	echo "    -  Usage    : $0 [service]"
	echo "    -  Example  : $0 keystone"
	exit 0
}

if [ -z $1 ]; then
	usage
else
	SVC_NAME=$1
fi

SVC_INTERFACE="public"
PUBLIC_IP="211.224.204.147"
FILE_SQL="my.sql"

# DB 접근 정보
DB_SERVER="211.224.204.147"
DB_USER=keystone
DB_PASS=ohhberry3333
DB=keystone

# Color codes
blue=$(tput setaf 4)
red=$(tput setaf 1)
normal=$(tput sgr0)

get_service_id() {
	SVC_NAME=$1
	keystone service-list | awk '/\ '$SVC_NAME'\ / {print $2}'
}



str_public_url() {
	SVC_NAME=$1

    # nova와 cinder, cinderv2는 url에 %가 들어가서 printf를 사용하기 어려워 echo를 이용
    if [ "$SVC_NAME" == "nova" ]; then
        PUBLIC_URL="http://$PUBLIC_IP:8774/v2/%\(tenant_id\)s"
        echo $PUBLIC_URL
    elif [ "$SVC_NAME" == "cinder" ]; then
        PUBLIC_URL="http://$PUBLIC_IP:8776/v1/%\(tenant_id\)s"
        echo $PUBLIC_URL
    elif [ "$SVC_NAME" == "cinderv2" ]; then
        PUBLIC_URL="http://$PUBLIC_IP:8776/v2/%\(tenant_id\)s"
        echo $PUBLIC_URL
    else
        PUBLIC_URL=${map_url["$SVC_NAME"]}
        printf $PUBLIC_URL $PUBLIC_IP
    fi
}

# endpoint update query를 생성해 이를 FILE_SQL 파일에 저장한다
# DB에 입력을 시도한 endpoint URL을 반환
generate_sql() {
	SVC_NAME=$1
	
	SERVICE_ID=$(get_service_id $SVC_NAME)
	PUBLIC_URL=$(str_public_url $SVC_NAME)

	SQL="update endpoint set url='${PUBLIC_URL}' where service_id = '${SERVICE_ID}' and interface = '$SVC_INTERFACE'"

	echo $SQL > $FILE_SQL

	echo $PUBLIC_URL
}

get_public_url() {
	SVC_NAME=$1

    SERVICE_ID=$(get_service_id $SVC_NAME)
   
    SQL="select url from endpoint where service_id = '${SERVICE_ID}' and interface = '$SVC_INTERFACE'"
	echo $SQL > $FILE_SQL

    execute_sql | awk '/http/ { print $0 }'
}

# FILE_SQL 파일에 저장된 query를 실행한다
execute_sql() {
	#cat $FILE_SQL
	mysql -h $DB_SERVER -u $DB_USER -p${DB_PASS} $DB < $FILE_SQL
}

# 신규 생성된 endpoint URL이 정상적으로 DB에 입력되었는지를 확인
check_result() {
	_1=$1
	_2=$2

	# URL에 '\'가 있으면 이를 제거 후 비교
	_1=$(echo $_1 | tr -d '\\')
	if [ "$_1" == "$_2" ]; then
		printf "${blue}OK!!!${normal}\n"
	else 
		printf "${red}Fail!!!${normal}\n"
		printf "\t - URL generated= %s\n" $_1
		printf "\t - URL in DB= %s\n" $_2
	fi
}

PUBLIC_URL_NEW=$(generate_sql $SVC_NAME)
execute_sql

check_result $PUBLIC_URL_NEW $(get_public_url $SVC_NAME)

