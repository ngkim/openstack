service libvirt-bin restart
service neutron-plugin-openvswitch-agent restart

for process in $(ls /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
do
	sudo stop ${process}
	sudo start ${process}
done
