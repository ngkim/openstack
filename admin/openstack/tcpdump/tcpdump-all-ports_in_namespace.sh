#!/bin/bash

source "$MNG_ROOT/include/print.sh"

_DIR_NS_DUMP="ns-dump"
FILE_NS_LIST="ns.list"

if [ ! -f $FILE_NS_LIST ]; then
  ip netns > $FILE_NS_LIST
fi

if [ -d $_DIR_NS_DUMP ]; then
  rm -rf $_DIR_NS_DUMP
  mkdir -p $_DIR_NS_DUMP
fi

for ns in `cat $FILE_NS_LIST`; do
  print_info "NSLIST" $ns
  ip netns exec $ns tcpdump -i any -ne -l -c 10 &> $_DIR_NS_DUMP/$ns.dump &
done

sleep 10
