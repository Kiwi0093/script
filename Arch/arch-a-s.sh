nge root內完成的)
#------------------------------------------------------------------------------
#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#update package
echo -e "${COLOR1}Start Pacman Update${NC}"
pacman -Syyuu
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

#change Timezone to CTS(Taipei)
echo -e "${COLOR1}Change Time Zone to Asia/Taipei & Set Hardware time${NC}"
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc --utc
echo -e "${COLOR2}Completed${NC}"

#Network
echo -n "${COLOR1}Please enter your hostname${NC}"
read HOSTNAME
echo {HOSTNAME} > /etc/hostname
echo "127.0.0.1 localhost ${HOSTNAME}" >> /etc/hosts
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your NIC by Mac address${NC}"
echo -n "${COLOR1}Please Enter your MAC address for your NIC${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="'${OUTSIDE}'", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your IP for EXT0:${NC}"
echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
echo "Interface=EXT0" >> /etc/netctl/EXT0.service
echo "Connection=ethernet" >> /etc/netctl/EXT0.service
echo "IP=static" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please Enter your EXT0 IP address:${NC}"
read EXT_IP
echo "Address=('${EXT_IP}/24')" >> /etc/netctl/EXT0.service
echo -n "${COLOR1}Please input your EXT Gateway IP:${NC}"
read GATE_IP
echo "Gateway='${GATE_IP}'"
echo -n "${COLOR1}Please Input your DNS IP:${NC}"
read DNS_IP
echo "DNS=('${DNS_IP}')"
echo -e "${COLOR2}Enable INT0${NC}"
netctl enable INT0.service
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
echo -e "${COLOR1}Microcode/grub/linux Kernel/dnsutils/open-vm-tools/vim/v2ray/screen${NC}"
pacman -Sy intel-ucode grub linux dnsutils open-vm-tools vim v2ray screen
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
