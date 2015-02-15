config_usage() {
	echo "* <function> load_config: load configuration file of a node based on its host name"
 	echo "  - Usage: load_config [node-to-configure]"
	echo "  - Load configuration of 'controller' node ($MNG_ROOT/conf/controller.conf)"
    echo "  - ex) load_config controller"  
}

load_config() {
	NODE=$1
	if [ -z $NODE ]; then
		config_usage; exit -1
	fi

	_CONF=$MNG_ROOT/conf/$NODE.conf
	if [ ! -f "$_CONF" ]; then
		config_usage; exit -1
	fi

	source "$MNG_ROOT/conf/$NODE.conf"
}


