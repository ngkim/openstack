# teardown 
teardown()
{
   	NODE=$1 
	print_title_small "$NODE - $CAP_HOME"
	ssh $NODE "$CAP_HOME/teardown.sh" &
}

# teardone all
teardown_all()
{
	NODES=$1
	for n in $NODES
	do
		teardown $n
	done
}
