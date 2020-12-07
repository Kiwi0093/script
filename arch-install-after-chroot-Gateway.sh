#-------------------------------------------------------------------------------------------------------------------------
#(所有動作都是在change root內完成的)
#-------------------------------------------------------------------------------------------------------------------------
#!/bin/zsh
#Parameter Define
COLOR='\033[1;34m'
NC='\033[0m'

#update package
echo -e "${COLOR}Start Pacman Update${NC}"
pacman -Syuu
echo -e "$COLOR}Finished.${NC}"

#locale-gen to add en_US & zh_TW
echo -e "${COLOR}Setting local file${NC}"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
echo -e "#{COLOR}Generate locale.conf${NC}"
locale-gen
echo -e "${COLOR}Setting locale.conf${NC}"
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "$COLOR}Finished.${NC}"

#change Timezone to CTS(Taipei)
echo -e "${COLOR}Change Time Zone to Asia/Taipei & Set Hardware time${NC}"
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc --utc
echo -e "$COLOR}Finished.${NC}"

#Network
echo -e "${COLOR}Setting 'Gateway' as hostname${NC}"
echo Gateway > /etc/hostname
echo "127.0.0.1 localhost Gateway" >> /etc/hosts
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Define your NIC by Mac address${NC}"
echo -n "${COLOR}Please Enter your MAC address for your outside NIC${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="$OUTSIDE", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -n "${COLOR}Please Enter your MAC address for your inside NIC${NC}"
read INSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="$INSIDE", NAME="INT0"' >> /etc/udev/rules.d/10-network.rules
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Define your PPPOE Setting${NC}"
echo "Description='EXT0 PPPOE SETTING'" > /etc/netctl/EXT0.service
echo "Interface=EXT0" >> /etc/netctl/EXT0.service
echo "Connection=pppoe" >> /etc/netctl/EXT0.service
echo -n "${COLOR}Please Enter your PPPOE acount:${NC}"
read ISP
echo "User='${ISP}'" >> /etc/netctl/EXT0.service
echo -n "${COLOR}Please Enter your PPPOE password${NC}"
read ISPPW
echo "Password='${ISPPW}'" >> /etc/netctl/EXT0.service
echo "ConnectionMode='persist'" >> /etc/netctl/EXT0.service
echo "UsePeerDNS=false" >> /etc/netctl/EXT0.service
echo -e "${COLOR}Enable EXT0{NC}"
netctl enable EXT0.service
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Define your Private Gateway IP for INT0${NC}"
echo "Description='INT0 IP SETTING'" > /etc/netctl/INT0.service
echo "Interface=INT0" >> /etc/netctl/INT0.service
echo "Connection=ethernet" >> /etc/netctl/INT0.service
echo "IP=static" >> /etc/netctl/INT0.service
echo -n "${COLOR}Please Enter your Gateway IP address:${NC}"
read GATEWAYIP
echo "Address=('${GATEWAYIP}/24')" >> /etc/netctl/INT0.service
echo -e "${COLOR}Enable INT0${NC}"
netctl enable INT0.service
echo -e "${COLOR}Finished.${NC}"

#Initramfs
#echo -e "${COLOR}Initramfs your Linux${NC}"
#mkinitcpio -p linux
#echo -e "${COLOR}Finished.${NC}"

#Root Password
echo -e "${COLOR}Set your root password${NC}"
passwd
chsh -s /bin/zsh
echo -e "${COLOR}Finished.${NC}"

#add User
echo -e "${COLOR}Add user account:${NC}"
echo -n "$What ID you want:${NC}"
read YOURID
useradd -m -g root -s /bin/zsh ${YOURID}
passwd ${YOURID}
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Add $YOURID into sudo list${NC}"
pacman -Syu sudo
echo "$YOURID ALL=(ALL) ALL" >> /etc/sudoers

#install Tools
echo -e "${COLOR}Install Packages Microcode/Bootloader - grub/dnsutils/open-vm-	tools/v2ray${NC}"
pacman -Sy intel-ucode grub dnsutils open-vm-tools v2ray screen
echo -e "${COLOR}Finished.${NC}"

#install Bootloader
echo -e "${COLOR}Install grub Boot Loader into /dev/sda1${NC}"
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${COLOR}Finished.${NC}"

#V2ray config.json get
echo -e "${COLOR}Fetch V2ray config.json and replace${NC}"
echo -n "${COLOR}Please Enter where you put the file:${NC}"
read link
echo -n "${COLOR}Please Enter the file name:${NC}"
read conffile
wget $Link/$conffile
mv -f  ./$conffile /etc/v2ray/config.json
echo -e "${COLOR}Finished.${NC}"

#Set Nat
echo -e "${COLOR}Open package fowrading${NC}"
echo "net.ipv4.ip_forward=1" > /etc/sysctl/30-ipforward.conf
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Create Iptable start script${NC}"
echo -n "${COLOR}Please Enter your V2ray Server IP:${NC}"
read VPSIP
echo "#Re-direction TCP" > /etc/iptables/iptable.sh
echo "iptables -t nat -N V2RAY" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 0.0.0.0/8 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 10.0.0.0/8 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 127.0.0.0/8 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 169.254.0.0/16 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 172.16.0.0/12-j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 192.168.0.0/16 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 224.0.0.0/4 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d 240.0.0.0/4 -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -d ${VPSIP} -j RETURN" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A V2RAY -p tcp -j REDIRECT --to-ports 12345" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A PREROUTING -p tcp -j V2RAY" >> /etc/iptables/iptable.sh
echo " " >> /etc/iptables/iptable.sh
echo "#Natd" >> /etc/iptables/iptable.sh
echo "iptables -t nat -A POSTROUTING -s 192.168/16 -j MASQUERADE" >> /etc/iptables/iptable.sh
chmod 750 /etc/iptables/iptable.sh
echo -e "${COLOR}Finished.${NC}"
echo -e "${COLOR}Create Systemd Service${NC}"
echo "[Unit] > /etc/systemd/system/iptables.service
echo "Description=iptables rules for V2Ray Daemon >> /etc/systemd/system/iptables.service
echo " " >> /etc/systemd/system/iptables.service
echo "[Service]" >> /etc/systemd/system/iptables.service
echo "ExecStart=/bin/sh /etc/iptables/iptable.sh" >> /etc/systemd/system/iptables.service
echo " " >> /etc/systemd/system/iptables.service
echo "[Install]" >> /etc/systemd/system/iptables.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/iptables.service
systemctl enable iptables.service
echo -e "${COLOR}Finished.${NC}"

#Finished install
sync
sync
sync
exit
