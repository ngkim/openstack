service keystone restart

service glance-api restart
service glance-registry restart

service neutron-server restart

service nova-api restart
service nova-scheduler restart
service nova-novncproxy restart
service nova-consoleauth restart
service nova-conductor restart
service nova-cert restart

service cinder-api restart
service cinder-scheduler restart
service cinder-volume restart

service apache2 restart
service memcached restart
service mysql restart