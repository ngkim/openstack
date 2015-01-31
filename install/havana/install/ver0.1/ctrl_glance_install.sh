#! /bin/bash

ctrl_glance_install() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_glance_install!!!
    # ------------------------------------------------------------------------------'
    
    echo 'glance service 설치'
    #Install Service
    apt-get update
    apt-get -y --force-yes install glance
    apt-get -y --force-yes install python-glanceclient 
    
    echo 'glance sqlite db 삭제(/var/lib/glance/glance.sqlite}'
    rm /var/lib/glance/glance.sqlite
    
    echo '>>> check result -----------------------------------------------------'    
    dpkg -l | egrep "glance|python-glanceclient "
    service glance-api status
    service glance-registry status
    echo '# --------------------------------------------------------------------'    

}

function ctrl_glance_uninstall() {

    echo '
    # --------------------------------------------------------------------------
    ### ctrl_keystone_uninstall
    # --------------------------------------------------------------------------'    
    
    echo '  ##service glance stop'
    service glance stop
    
    echo '>>> before uninstall glance ----------------------------------------'
    dpkg -l | grep glance    
    echo '#---------------------------------------------------------------------'
    
    echo '  ##apt-get -y purge glance'
    apt-get -y purge glance glance-api glance-common glance-registry python-glance python-glanceclient
    
    echo '>>> after uninstall glance -----------------------------------------'
    dpkg -l | grep glance    
    echo '#---------------------------------------------------------------------'
    
}    

ctrl_glance_db_create() {

    echo '
    # --------------------------------------------------------------------------
    ### ctrl_glance_db_create!!!
    # -------------------------------------------------------------------------'

    echo '  2 glance 데이터베이스 생성 및 권한 설정'
    
    #Create database
    mysql -uroot -p$MYSQL_ROOT_PASS -e 'CREATE DATABASE glance;'
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"
    mysql -uroot -p$MYSQL_ROOT_PASS -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$MYSQL_GLANCE_PASS';"

    echo '>>> check result -----------------------------------------------------'    
    mysql -u root -p${MYSQL_ROOT_PASS} -h localhost -e "show databases;"
    echo '# --------------------------------------------------------------------'    

}

ctrl_glance_paste_ini_configure() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_glance_paste_ini_configure !!!
    # ------------------------------------------------------------------------------' 

    echo "## ${GLANCE_API_INI} ) 구성"
    cp ${GLANCE_API_INI}{,.bak}
    
    echo "
[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
auth_host = $KEYSTONE_ENDPOINT
auth_port = 35357
auth_protocol = http
admin_tenant_name = $SERVICE_TENANT
admin_user = $GLANCE_SERVICE_USER
admin_password = $GLANCE_SERVICE_PASS" | tee -a ${GLANCE_API_INI}


    
    echo "## ${GLANCE_REGISTRY_INI} ) 구성"
    cp ${GLANCE_REGISTRY_INI}{,.bak}
    
    echo "
[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory
auth_host = $KEYSTONE_ENDPOINT
auth_port = 35357
auth_protocol = http
admin_tenant_name = $SERVICE_TENANT
admin_user = $GLANCE_SERVICE_USER
admin_password = $GLANCE_SERVICE_PASS" | tee -a ${GLANCE_REGISTRY_INI}

    echo '>>> check result ----------------------------------------------------'
    echo "cat $GLANCE_API_INI"    
    cat $GLANCE_API_INI
    echo '# -------------------------------------------------------------------'
    echo "cat $GLANCE_REGISTRY_INI" 
    cat $GLANCE_REGISTRY_INI   
    echo '# -------------------------------------------------------------------' 

}

ctrl_glance_api_registry_configure() {
   
    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_glance_api_registry_configure!!!
    # ------------------------------------------------------------------------------' 
    
    echo "##  glance api service 구성(${GLANCE_API_CONF})"
    cp ${GLANCE_API_CONF}{,.bak}
    sed -i 's/^#known_stores.*/known_stores = glance.store.filesystem.Store,\
                   glance.store.http.Store,\
                   glance.store.swift.Store/' ${GLANCE_API_CONF}
    
    sed -i "s/127.0.0.1/$KEYSTONE_ENDPOINT/g" $GLANCE_API_CONF         
    sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT/g" $GLANCE_API_CONF
    sed -i "s/%SERVICE_USER%/$GLANCE_SERVICE_USER/g" $GLANCE_API_CONF
    sed -i "s/%SERVICE_PASSWORD%/$GLANCE_SERVICE_PASS/g" $GLANCE_API_CONF    
    
    # LJG: icehouse conf
    # sed -i "s,^#connection.*,connection = mysql://glance:${MYSQL_GLANCE_PASS}@${MYSQL_HOST}/glance," ${GLANCE_API_CONF}
    # LJG: havana conf
    sed -i "s,sql_connection.*,sql_connection = mysql://glance:${MYSQL_GLANCE_PASS}@${MYSQL_HOST}/glance," ${GLANCE_API_CONF}
    
    echo '##  glance-api syslog 설정'
    
    echo "use_syslog = True" >> ${GLANCE_API_CONF}
    echo "syslog_log_facility = LOG_LOCAL0" >> ${GLANCE_API_CONF}
    
    echo "
[paste_deploy]
config_file = ${GLANCE_API_INI}
flavor = keystone" | tee -a ${GLANCE_API_CONF}  
    
    
    echo '##  glance registry service 구성(${GLANCE_REGISTRY_CONF})'
    cp ${GLANCE_REGISTRY_CONF}{,.bak}
    sed -i 's/^#known_stores.*/known_stores = glance.store.filesystem.Store,\
                   glance.store.http.Store,\
                   glance.store.swift.Store/' ${GLANCE_REGISTRY_CONF}
    
    sed -i "s/127.0.0.1/$KEYSTONE_ENDPOINT/g" $GLANCE_REGISTRY_CONF
    sed -i "s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT/g" $GLANCE_REGISTRY_CONF
    sed -i "s/%SERVICE_USER%/$GLANCE_SERVICE_USER/g" $GLANCE_REGISTRY_CONF
    sed -i "s/%SERVICE_PASSWORD%/$GLANCE_SERVICE_PASS/g" $GLANCE_REGISTRY_CONF
    
    # LJG: icehouse conf
    #sed -i "s,^#connection.*,connection = mysql://glance:${MYSQL_GLANCE_PASS}@${MYSQL_HOST}/glance," ${GLANCE_REGISTRY_CONF}
    
    # LJG: havana conf 
    sed -i "s,sql_connection.*,sql_connection = mysql://glance:${MYSQL_GLANCE_PASS}@${MYSQL_HOST}/glance," ${GLANCE_REGISTRY_CONF}
    
    echo '##  glance-registry syslog 설정'
    echo "use_syslog = True" >> ${GLANCE_REGISTRY_CONF}
    echo "syslog_log_facility = LOG_LOCAL0" >> ${GLANCE_REGISTRY_CONF}
    
    # LJG: 구성파일은 모두 라인시작에 공백이 없어야 한다.
    #      파이썬에서 파싱에러 발생할 수 있슴
    echo "
[paste_deploy]
config_file = ${GLANCE_REGISTRY_INI}
flavor = keystone" | tee -a ${GLANCE_REGISTRY_CONF}
    

    echo '>>> check result -----------------------------------------------------'
    echo "cat $GLANCE_API_CONF"    
    cat $GLANCE_API_CONF
    echo '# --------------------------------------------------------------------'
    echo "cat $GLANCE_REGISTRY_CONF" 
    cat $GLANCE_REGISTRY_CONF    
    echo '# --------------------------------------------------------------------' 

}

ctrl_glance_restart() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_glance_restart!!!
    # ------------------------------------------------------------------------------' 
    
    echo '  ## glance service 재시작'
    stop glance-registry
    start glance-registry
    stop glance-api
    start glance-api
    
    echo '  ## glance db 동기화'
    glance-manage db_sync
 
    echo '>>> check result -----------------------------------------------------'    
    ps -ef | grep glance
    echo '# --------------------------------------------------------------------'    
}


ctrl_glance_demo_image_create() {

    echo '
    # ------------------------------------------------------------------------------
    ### ctrl_glance_demo_image_create(cirros/ubuntu) !!!
    # ------------------------------------------------------------------------------'    
    
    if [[ ! -f ./${CIRROS_IMAGE} ]]
    then
        # Download then store on local host for next time
        wget https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img -O ./${CIRROS_IMAGE}
    fi
    
    if [[ ! -f ./${UBUNTU_IMAGE} ]]
    then
        # Download then store on local host for next time
        # wget --quiet http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img -O ./${UBUNTU_IMAGE}
        wget http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img -O ./${UBUNTU_IMAGE}
    fi
    
    echo "glance image-create --name='cirros-image' --disk-format=qcow2 --container-format=bare --public < ./${CIRROS_IMAGE}"
    glance image-create --name='cirros-image' --disk-format=qcow2 --container-format=bare --public < ./${CIRROS_IMAGE}
    echo "glance image-create --name='ubuntu-14.04' --disk-format=qcow2 --container-format=bare --public < ./${UBUNTU_IMAGE}"
    glance image-create --name='ubuntu-14.04' --disk-format=qcow2 --container-format=bare --public < ./${UBUNTU_IMAGE}
    
    
    echo '>>> check result -----------------------------------------------------'    
    glance image-list
    echo '# --------------------------------------------------------------------'   
}