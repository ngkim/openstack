# cleanup
# - remove all log files
# - kill all hanged ssh
cleanup()
{
	BACKUP_DIR=$MNG_ROOT/logs/backup/$(date '+%F')
	mkdir -p $BACKUP_DIR
	mv $MNG_ROOT/logs/iperf* $BACKUP_DIR
	ps | grep ssh | grep -v grep | awk '{print $1}' | xargs kill -9 &> /dev/null
}
