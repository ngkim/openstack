
for process in $(ls /etc/init/neutron* | cut -d'/' -f4 | cut -d'.' -f1)
do
	sudo stop ${process}
	sudo start ${process}
done
service openvswitch-switch restart
service dnsmasq restart

