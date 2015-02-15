restart_nova() {
	print_info $MODE "Restart all nova services:"
	cd /etc/init.d/; for i in $( ls nova* ); do sudo service $i restart; done
}
