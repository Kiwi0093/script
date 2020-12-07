#------------------------------------------------------------------------------
#(所有動作都是在change root內完成的)
#------------------------------------------------------------------------------
#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#change Timezone to CTS(Taipei)
echo -e "${COLOR1}請選擇你想要設定的時區\n1)台北\n2)上海\n*)不用管時間隨便\n${NC}"
while:
do
	read ZONE
	case $ZONE in
		1)
			ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
			hwclock --systohc --utc
			exit
			;;
		2)
			ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
			hwclock --systohc --utc
			exit
			;;
		*)
			hwclock --systohc --utc
			exit
			;;
	esac
done
echo -e "${COLOR2}Completed${NC}"

#Set Mac Address
echo -e "${COLOR1}Define your NIC by Mac address${NC}"
echo -e "${COLOR1}請輸入你的對外網路卡MAC Address:\n${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${OUTSIDE}'", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR1}請輸入你的對內網路卡MAC Address:\n${NC}"
read INSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${INSIDE}'", NAME="INT0"' >> /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

# Set INT network
echo -e "${COLOR1}現在開始設定你的對內網路${NC}"
echo "Description='INT0 IP SETTING'" > /etc/netctl/INT0.service
echo "Interface=INT0" >> /etc/netctl/INT0.service
echo "Connection=ethernet" >> /etc/netctl/INT0.service
echo "IP=static" >> /etc/netctl/INT0.service
echo -e "${COLOR1}請輸入你的對內IP地址:\n${NC}"
read INT_IP
echo "Address=('${INT_IP}/24')" >> /etc/netctl/INT0.service
echo -e "${COLOR2}Enable INT0${NC}"
netctl enable INT0.service
echo -e "${COLOR2}Finished.${NC}"

# Set EXT network
echo -e "${COLOR1}請選擇你的對外連線方式\n1)PPPOE方式連線\n2)固定IP\n"
while
do
	read CONNECT
	case $CONNECT in
		1)
			echo -e "${COLOR1}現在開始設定你的PPPOE連線${NC}"
			echo "Description='EXT0 PPPOE SETTING'" > /etc/netctl/EXT0.service
			echo "Interface=EXT0" >> /etc/netctl/EXT0.service
			echo "Connection=pppoe" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}請輸入你的撥接帳號:\n:${NC}"
			read ISP
			echo "User='${ISP}'" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}請輸入你的撥接密碼\n${NC}"
			read ISPPW
			echo "Password='${ISPPW}'" >> /etc/netctl/EXT0.service
			echo "ConnectionMode='persist'" >> /etc/netctl/EXT0.service
			echo "UsePeerDNS=false" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}Enable EXT0{NC}"
			netctl enable EXT0.service
			exit
			;;
		2)
			echo -e "${COLOR1}現在開始設定你的對外固定IP連線${NC}"
			echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
			echo "Interface=EXT0" >> /etc/netctl/EXT0.service
			echo "Connection=ethernet" >> /etc/netctl/EXT0.service
			echo "IP=static" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}請輸入你的IP地址:\n${NC}"
			read EXT_IP
			echo "Address=('${EXT_IP}/24')" >> /etc/netctl/EXT0.service
			echo -e "${COLOR1}請輸入你的Gateway的IP地址:\n${NC}"
			read GATE_IP
			echo "Gateway='${GATE_IP}'"
			echo -e "${COLOR1}請輸入你的DNS的IP:\n${NC}"
			read DNS_IP
			echo "DNS=('${DNS_IP}')"
			echo -e "${COLOR2}Enable EXT0${NC}"
			netctl enable EXT0.service
			exit
			;;
	esac
done
echo -e "${COLOR2}對外網路設定完成${NC}"

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
echo -e "${COLOR1}設定你的root密碼${NC}"
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
pacman -Sy screen v2ray
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
