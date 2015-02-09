#!/bin/bash

USER_NAME=admin
USER_PASS=ohhberry333
TENANT=admin
KEYSTONE=http://10.0.0.101:5000/v2.0/
#KEYSTONE=http://211.224.204.147:5000/v2.0/

SERVER_NAME="api-test"

get_token_id() {
  curl -d '
{ "auth" : 
  { 
    "passwordCredentials" : {
      "username" : "'$USER_NAME'", 
      "password" : "'$USER_PASS'"
    },
    "tenantName" : "'$TENANT'"
  }
}' -H "Content-Type: application/json" $KEYSTONE/tokens 2> /dev/null | jq -r .access.token.id ; echo
}

get_tenant_id() {
  TOKEN=$1
  curl -H "X-Auth-Token: $TOKEN" $KEYSTONE/tenants 2> /dev/null | jq -r .tenants[0].id ; echo
}

create_instance() {
  TENANT_ID=$1

  curl -d '
{ "tenant_id" : "'$TENANT_ID'" ,
  "name" : "'$SERVER_NAME'",

  { 
    "passwordCredentials" : {
      "username" : "'$USER_NAME'", 
      "password" : "'$USER_PASS'"
    },
    "tenantName" : "'$TENANT'"
  }
}' -H "Content-Type: application/json" $KEYSTONE/tokens 2> /dev/null
}

TOKEN=$(get_token_id)
TENANT_ID=$(get_tenant_id $TOKEN)

echo $TENANT_ID
