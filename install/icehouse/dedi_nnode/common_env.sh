#!/bin/bash

#
# LJG: install openstack as root : what a lazy !!!
#   prerequisite:
#       1. setting editor encoding option -> utf8: file -> convert -> unicode utf8
#       2. convert *.sh files to utf8, ex) acroedit:
#
#

echo '
################################################################################
    common_env.sh 실행
################################################################################
'

echo '
--------------------------------------------------------------------------------
    openstack install topology 설정에 따른 global_env 설정
--------------------------------------------------------------------------------'
source ./common_openstack_topology_global_env
    # openstack_install_1nodes_env
    # openstack_install_2nodes_env
    openstack_install_3nodes_env

echo '
--------------------------------------------------------------------------------
    allinone_global_variable_setting 설정
--------------------------------------------------------------------------------'
source ./allinone_global_variable_setting.sh

    
echo '
--------------------------------------------------------------------------------
    common_openstack_global_conf_variable 설정
--------------------------------------------------------------------------------'
source ./common_openstack_global_conf_variable