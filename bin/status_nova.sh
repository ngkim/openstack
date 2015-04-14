

for process in $(ls /etc/init/nova* | cut -d'/' -f4 | cut -d'.' -f1)
do
	sudo service ${process} status
done

sudo service libvirt-bin status
