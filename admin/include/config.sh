# 1. get_CTRLIP
# 2. get_IP
# 3. get_PRIV_IFNAME
# 4. get_PRIV_IP
# 5. get_USER_ID

source "$MNG_ROOT/conf/openflow.cfg"

get_CTRLIP()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $3}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done <$TB_CONFIG

	echo $re | tr -d ' '
}

get_IP()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $2}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done < $TB_CONFIG

	echo $re | tr -d ' '
}

get_PRIV_IFNAME()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $4}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done < $TB_CONFIG

	echo $re | tr -d ' '
}

get_PRIV_IP()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $7}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done < $TB_CONFIG

	echo $re | tr -d ' '
}

get_SSH_Port()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $6}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done < $TB_CONFIG

	echo $re | tr -d ' '
}

get_USER_ID()
{
	re="";
	hostname=$1

	while read line
	do
		re=$(echo $line | awk -v hostname=$1 '$1==hostname {printf "%s\n", $5}')
		if [ "$re" != "" ]; then
			 break; 
		fi
	done < $TB_CONFIG

	echo $re | tr -d ' '
}

# 1. get_CTRLIP
# 2. get_IP
# 3. get_PRIV_IFNAME
# 4. get_PRIV_IP
# 5. get_USER_ID

test_config() {

	while read line
	do
		hostname=$(echo $line | awk '{printf "%s", $1}')
		echo $hostname $(get_IP $hostname) $(get_CTRLIP $hostname) $(get_PRIV_IFNAME $hostname) $(get_USER_ID $hostname) $(get_SSH_Port $hostname) $(get_PRIV_IP $hostname)
	done < $TB_CONFIG
}

#test_config
