#------------------------------------------------------------------------------
#(所有動作都是在change root內完成的)
#------------------------------------------------------------------------------
#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#change Timezone to CTS(Taipei)
echo -e "${COLOR1}Please select your time zone\n1)Taipei\n2)Shanghai\n*)Whatever..I don't care\n${NC}"
while :
do
	read ZONE
	case $ZONE in
		1)
			echo -e "${COLOR1}Set Time Zone to Asia/Taipei${NC}"
			ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
			hwclock --systohc --utc
			break
			;;
		2)
			echo -e "${COLOR1}Set Time Zone to Asia/Shanghai${NC}"
			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
			hwclock --systohc --utc
			break
			;;
		*)
			echo -e "${COLOR1}Nobody cares the local time!!${NC}"
			hwclock --systohc --utc
			break
			;;
	esac
done
echo -e "${COLOR2}Completed${NC}"

#Hostname
echo -e "${COLOR1}Please input your hostname\n${NC}"
read HOSTNAME
echo ${HOSTNAME} > /etc/hostname
echo "127.0.0.1 localhost ${HOSTNAME}" >> /etc/hosts
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your NIC by Mac address${NC}"
echo -e "${COLOR1}Please input your MAC Address:\n${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${OUTSIDE}'", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your IP for EXT0:${NC}"
echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
echo "Interface=EXT0" >> /etc/netctl/EXT0.service
echo "Connection=ethernet" >> /etc/netctl/EXT0.service
echo "IP=static" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your IP address:\n${NC}"
read EXT_IP
echo "Address=('${EXT_IP}/24')" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your Gateway IP address:\n${NC}"
read GATE_IP
echo "Gateway='${GATE_IP}'" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your DNS IP address:\n${NC}"
read DNS_IP
echo "DNS=('${DNS_IP}')" >> /etc/netctl/EXT0.service
echo -e "${COLOR2}Enable EXT0${NC}"
netctl enable EXT0.service
echo -e "${COLOR2}Finished.${NC}"

#Root Password
echo -e "${COLOR1}Set your root password${NC}"
passwd
chsh -s /bin/zsh
echo -e "${COLOR2}Completed${NC}"

#add User
echo -e "${COLOR1}Add user account:${NC}"
echo -n "${COLOR1}What ID you want:${NC}"
read YOURID
useradd -m -g root -s /bin/zsh ${YOURID}
passwd ${YOURID}
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Add $YOURID into sudo list${NC}"
pacman -Syu sudo
echo "${YOURID} ALL=(ALL) ALL" >> /etc/sudoers
echo -e "${COLOR2}Completed${NC}"

#install Tools
echo -e "${COLOR1}Install Packages${NC}"
echo -e "${COLOR1}screen${NC}"
pacman -Syu screen v2ray certbot python3-certbot-nginx
echo -e "${COLOR2}Completed${NC}"

#install Bootloader
echo -e "${COLOR1}Install grub Boot Loader into /dev/sda${NC}"
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${COLOR2}Completed${NC}"

#Finished install
sync
sync
sync
exit
