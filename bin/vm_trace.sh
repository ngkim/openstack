#!/bin/bash

vm=$1

if [ $vm ]
then
    echo "######################################################################"
    echo " [$vm] trace"        
    echo "######################################################################"
else
    echo "
        usage:: vm_trace.sh vm_name
        ex) vm_trace.sh ubuntu-12.04
        "
    exit
fi

query="
    SELECT start_time, finish_time, vm_name, action, event, result, traceback 
    FROM nova.vw_vm_trace 
    WHERE vm_name='$vm'
    order by start_time
"

echo
echo $query
echo
# mysql -uroot -pohhberry3333 -B --column-names=0 -s -e "$query"
mysql -uroot -pohhberry3333 -B -s -e "$query"

exit



recs=$(echo $query | mysql -N -uroot -pohhberry3333)
#echo $recs
rm data.csv
echo $query | mysql -N -uroot -pohhberry3333 | tr '\t' ',' > data.csv
echo
echo "##########################################################################"
cat data.csv
echo "##########################################################################"
echo $query | mysql -N -uroot -pohhberry3333 | tr '\t' ','                                       
echo "##########################################################################"                
echo $query | mysql -N -uroot -pohhberry3333 | sed "s/'/\'/;s/\t/\",\"/g;s/^/\"/;s/$/\"/;s/\n//g"
echo
echo "##########################################################################"
echo "vm_name | action | event | start_time | finish_time | result | details "
echo "##########################################################################"
echo $query | mysql -N -uroot -pohhberry3333
echo "##########################################################################"

CREATE VIEW 'vw_trace' AS 
    SELECT
        a.display_name AS vm_name,
        b.action       AS ACTION,
        c.event        AS event,
        c.start_time   AS start_time,
        c.finish_time  AS finish_time,
        c.result       AS result,
        c.traceback    AS traceback
    FROM 
        instances a,
        instance_actions b,
        instance_actions_events c
    WHERE a.uuid = b.instance_uuid
        AND b.id = c.action_id

    UNION 

    SELECT
        a.display_name  AS vm_name,
        b.host          AS HOST,
        '#instance fault',
        b.created_at    AS created_at,
        b.deleted_at    AS deleted_at,
        b.message       AS message,
        b.details       AS details
    FROM 
        instances a,
        instance_faults b
    WHERE a.uuid = b.instance_uuid



