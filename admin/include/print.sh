source "$MNG_ROOT/include/util.sh"

red='\e[0;31m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
GREEN='\e[1;32m'

print_title ()
{
	echo ""
	echo "########################################################################################"
	echo $1
	echo "########################################################################################"
}

print_title_middle()
{
	echo ""
	echo "========================================================================================"
	echo "      $1 "
	echo "----------------------------------------------------------------------------------------"
}

print_title_end()
{
	echo "========================================================================================"
}

print_title_small()
{
	MSG=$1
	echo ""
	echo "===== $MSG ====="
}

print_msg()
{
	MODULE=$1

	if [ $# -gt 2 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
	else
		MSG=$2
	fi
	echo "$(__get_time) >> [_LOG:$MODULE] $MSG"
}

print_strong()
{
	MODULE=$1

	if [ $# -gt 2 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
		MSG=$2
	else
		MSG=$2
	fi

	echo -e "$cyan$(__get_time) >> [INFO:$MODULE] $MSG\033[0m"
}

print_info()
{
	MODULE=$1

	if [ $# -gt 2 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
		MSG=$2
	else
		MSG=$2
	fi

	echo -e "$GREEN$(__get_time) >> [INFO:$MODULE] $MSG\033[0m"
}

print_info_nodate()
{
	if [ $# -gt 1 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
		MSG=$1
	else
		MSG=$1
	fi

	echo -e "$GREEN $MSG\033[0m"
}

print_warn()
{
	MODULE=$1

	if [ $# -gt 2 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
	else
		MSG=$2
	fi

	echo -e "$BLUE$(__get_time) >> [WARN:$MODULE] $MSG\033[0m"
}

print_err()
{
	MODULE=$1

	if [ $# -gt 2 ]; then
		MSG=$(echo $@ | awk 'BEGIN{str = ""}{for (i = 1; i <= NF; i++) { if( i != 1) str = str" "$i }} END{print str}' | sed 's/^ //g')
	else
		MSG=$2
	fi

	echo -e "$RED$(__get_time) >> [_ERR:$MODULE] $MSG\033[0m"
}

print_space()
{
	echo ""
	echo ""
}

