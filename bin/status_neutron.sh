
for process in $(ls /etc/init/neutron* | cut -d'/' -f4 | cut -d'.' -f1)
do
	sudo service ${process} status
done
service openvswitch-switch status
service dnsmasq status

