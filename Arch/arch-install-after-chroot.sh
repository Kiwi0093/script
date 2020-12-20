#-------------------------------------------------------------------------------------------------------------------------
#(所有動作都是在change root內完成的)
#-------------------------------------------------------------------------------------------------------------------------
#!/bin/zsh
#Parameter Define
COLOR='\033[1;34m'
NC='\033[0m'

#update package
echo -e "${COLOR}Start Pacman Update & install basic tools${NC}"
pacman -Syuu linux-lts netctl mkinitcpio intel-ucode os-prober open-vm-tools dnsutils vim grub git zsh
echo -e "${COLOR}Finished.${NC}"

#locale-gen to add en_US & zh_TW
echo -e "${COLOR}Setting local file${NC}"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "zh_TW.UTF-8 UTF-8" >> /etc/locale.gen
echo -e "${COLOR}Generate locale.conf${NC}"
locale-gen
echo -e "${COLOR}Setting locale.conf${NC}"
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "${COLOR}Finished.${NC}"

#change Timezone to CTS(Taipei)
echo -e "${COLOR}Change Time Zone to Asia/Taipei & Set Hardware time${NC}"
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
hwclock --systohc --utc
echo -e "${COLOR}Finished.${NC}"

#Network
echo -e "${COLOR}Setting hostname${NC}"
echo -n "${COLOR}Please input your hostname: ${NC}"
read hostsname
echo ${hostsname} > /etc/hostname
echo "127.0.0.1 localhost ${hostsname}" >> /etc/hosts
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Define your NIC by Mac address: ${NC}"
echo -n "${COLOR}Please Enter your MAC address for your NIC: ${NC}"
read OUTSIDE
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${OUTSIDE}", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Setup your Static Network for EXT0${NC}"
echo "Description='EXT0 IP SETTING'" > /etc/netctl/EXT0.service
echo "Interface=EXT0" >> /etc/netctl/EXT0.service
echo "Connection=ethernet" >> /etc/netctl/EXT0.service
echo "IP=static" >> /etc/netctl/EXT0.service
echo -n "${COLOR}Please Enter your IP address:${NC}"
read MYIP
echo "Address=('${MYIP}/24')" >> /etc/netctl/EXT0.service
echo -n "${COLOR}Please Enter your Gateway address:${NC}"
read GATEWAYIP
echo "Gateway=('${GATEWAYIP}')" >> /etc/netctl/EXT0.service
echo -n "${COLOR}Please Enter your DNS address:${NC}"
read DNSIP
echo "DNS=('${DNSIP}')" >> /etc/netctl/EXT0.service
echo -e "${COLOR}Enable EXT0${NC}"
netctl enable EXT0.service
echo -e "${COLOR}Finished.${NC}"

#Root Password
echo -e "${COLOR}Set your root password${NC}"
passwd
chsh -s /bin/zsh
echo -e "${COLOR}Finished.${NC}"

#add User
echo -e "${COLOR}Add user account:${NC}"
echo -n "$What ID you want: ${NC}"
read YOURID
useradd -m -g root -s /bin/zsh ${YOURID}
passwd ${YOURID}
echo -e "${COLOR}Finished.${NC}"

echo -e "${COLOR}Add $YOURID into sudo list${NC}"
echo "${YOURID} ALL=(ALL) ALL" >> /etc/sudoers

#Build Ramdisk image
echo -e "${COLOR}update initial Ramdisk${NC}"
mkinitcpio -p linux
echo -e "${COLOR}Completed${NC}"

#install Bootloader
echo -e "${COLOR}Install grub Boot Loader into /dev/sda${NC}"
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${COLOR}Finished.${NC}"

#Finished install
sync
sync
sync
exit
