#!/bin/sh
#Parmeter Pre-Define
#Color for warning
COLOR_W='\e[35m'
#Color for description
COLOR1='\e[94m'
COLOR2='\e[32m'
# Color for Highlight package
COLOR_H1='\e[96m'
COLOR_H2='\e[34m'
NC='\e[0m'

#Notice before use
echo -e "${COLOR_W}=====================Warning=======================\n${NC}"
echo -e "${COLOR_W}=  Kiwi's Arch linux Auto install script Ver.1.1  =\n${NC}"
echo -e "${COLOR_W}=  Simple Arch linus Install script Ver.1.1       =\n${NC}"
echo -e "${COLOR_W}=  This Script for Kiwi private use.              =\n${NC}"
echo -e "${COLOR_W}=  If you have any issue on usage,                =\n${NC}"
echo -e "${COLOR_W}=  Please DON'T Feedback to Kiwi                  =\n${NC}"
echo -e "${COLOR_W}=  And you should take your own responsibility    =\n${NC}"
echo -e "${COLOR_W}===================================================\n${NC}"

#change Timezone
echo -e "${COLOR1}Please select your time zone\n${NC}${COLOR_H1}1)Taipei\n2)Shanghai\n*)Whatever..I don't care\n${NC}"
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

#locale-gen to add en_US & zh_TW
echo -e "${COLOR1}Setting local file${NC}"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
echo -e "${COLOR1}Generate locale.conf${NC}"
locale-gen
echo -e "${COLOR1}Setting locale.conf${NC}"
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "${COLOR2}Completed${NC}"

#Hostname
echo -e "${COLOR1}Please input your hostname\n${NC}"
read HOSTNAME
echo ${HOSTNAME} > /etc/hostname
echo "127.0.0.1 localhost ${HOSTNAME}" >> /etc/hosts
echo -e "${COLOR2}Completed${NC}"

#Set Mac Address
echo -e "${COLOR1}Define your NIC by Mac address${NC}"
echo -e "${COLOR1}Please input your EXT Mac Address(need to be lowcase):\n${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${OUTSIDE}'", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR1}Please input your INT Mac Address(need to be lowcase):\n${NC}"
read INSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${INSIDE}'", NAME="INT0"' >> /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

# Set INT network
echo -e "${COLOR1}Setting your INT0${NC}"
echo "Description='INT0 IP SETTING'" > /etc/netctl/INT0.service
echo "Interface=INT0" >> /etc/netctl/INT0.service
echo "Connection=ethernet" >> /etc/netctl/INT0.service
echo "IP=static" >> /etc/netctl/INT0.service
echo -e "${COLOR1}Please input your INT IP:\n${NC}"
read INT_IP
echo "Address=('${INT_IP}/24')" >> /etc/netctl/INT0.service
echo -e "${COLOR2}Enable INT0${NC}"
netctl enable INT0.service
echo -e "${COLOR2}Finished.${NC}"

# Set EXT network
echo -e "${COLOR1}Please select your connection\n${NC}${COLOR_H1}1)PPPOE\n2)Static IP\n${NC}"
while
do
	read CONNECT
	case $CONNECT in
		1)
			echo -e "${COLOR1}Setting your PPPOE${NC}"
			echo "Description='EXT0 PPPOE SETTING'" > /etc/netctl/EXT0.service
			echo "Interface=EXT0" >> /etc/netctl/EXT0.service
			echo "Connection=pppoe" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Please input your PPPOE Account:\n:${NC}"
			read ISP
			echo "User='${ISP}'" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Please input your PPPOE password:\n${NC}"
			read ISPPW
			echo "Password='${ISPPW}'" >> /etc/netctl/EXT0.service
			echo "ConnectionMode='persist'" >> /etc/netctl/EXT0.service
			echo "UsePeerDNS=false" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Enable EXT0{NC}"
			netctl enable EXT0.service
			break
			;;
		2)
			echo -e "${COLOR1}Setting your Static IP${NC}"
			echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
			echo "Interface=EXT0" >> /etc/netctl/EXT0.service
			echo "Connection=ethernet" >> /etc/netctl/EXT0.service
			echo "IP=static" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Please input your IP address:\n${NC}"
			read EXT_IP
			echo "Address=('${EXT_IP}/24')" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Please input Gateway IP address:\n${NC}"
			read GATE_IP
			echo "Gateway='${GATE_IP}'" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Please input DNS IP address:\n${NC}"
			read DNS_IP
			echo "DNS=('${DNS_IP}')" >> /etc/netctl/EXT0.service
			echo -e "${COLOR2}Enable EXT0${NC}"
			netctl enable EXT0.service
			break
			;;
	esac
done
echo -e "${COLOR2}EXT set completed.${NC}"

#Set Nat
echo -e "${COLOR1}Open package fowrading${NC}"
echo "net.ipv4.ip_forward=1" > /etc/sysctl/30-ipforward.conf
echo -e "${COLOR2}Finished.${NC}"

# iptable script
echo -e "${COLOR1}Create Iptable start script${NC}"
echo "#Natd" > /etc/iptables/iptable.sh
echo "iptables -t nat -A POSTROUTING -s 192.168/16 -j MASQUERADE" >> /etc/iptables/iptable.sh
chmod 750 /etc/iptables/iptable.sh
echo -e "${COLOR2}Finished.${NC}"

# systemd
echo -e "${COLOR1}Create Systemd Service${NC}"
echo "[Unit] > /etc/systemd/system/iptables.service
echo "Description=iptables rules >> /etc/systemd/system/iptables.service
echo " " >> /etc/systemd/system/iptables.service
echo "[Service]" >> /etc/systemd/system/iptables.service
echo "ExecStart=/bin/sh /etc/iptables/iptable.sh" >> /etc/systemd/system/iptables.service
echo " " >> /etc/systemd/system/iptables.service
echo "[Install]" >> /etc/systemd/system/iptables.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/iptables.service
systemctl enable iptables.service
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
echo -e "${COLOR1}tmux, V2ray ${NC}"
pacman -Sy tmux v2ray
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
