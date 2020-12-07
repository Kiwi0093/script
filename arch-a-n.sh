nge root內完成的)
#------------------------------------------------------------------------------
#!/bin/zsh
#Parmeter Pre-Define
COLOR1='\e[94m'
COLOR2='\e[32m'
NC='\e[0m'

#update package
echo -e "${COLOR1}Start Pacman Update${NC}"
pacman -Syuu
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
echo 'SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="${OUTSIDE}", NAME="EXT0"' > /etc/udev/rules.d/10-network.rules
echo -e "${COLOR2}Completed${NC}"

echo -e "${COLOR1}Define your IP for EXT0${NC}"
mkdir /etc/conf.d
echo n "${COLOR1}Please input your IP address${NC}"
read EXT_IP
echo "address=${EXT_IP}" > /etc/conf.d/network@EXT0
echo n "${COLOR1}Please input your mask(ie, 24)${NC}"
read EXT_MASK
echo "netmask=${EXT_MASK}" >> /etc/conf.d/network@EXT0
echo n "${COLOR1}Please input your broadcast(ie, 192.168.0.255)${NC}"
read EXT_CAST
echo "broadcast=${EXT_CAST}" >> /etc/conf.d/network@EXT0
echo n "${COLOR1}Please input your Gateway IP${NC}"
read EXT_GATE
echo "gateway=${EXT_GATE}" >> /etc/conf.d/network@EXT0

echo -e "${COLOR1}Establish Systemd file${NC}"
echo "[Unit]" > /etc/systemd/system/network@.service
echo "Description=Network connectivity (%i)" >> /etc/systemd/system/network@.service
echo "Wants=network.target" >> /etc/systemd/system/network@.service
echo "Before=network.target" >> /etc/systemd/system/network@.service
echo "BindsTo=sys-subsystem-net-devices-%i.device" >> /etc/systemd/system/network@.service
echo "After=sys-subsystem-net-devices-%i.device" >> /etc/systemd/system/network@.service
echo " " >> /etc/systemd/system/network@.service
echo "[Service]" >> /etc/systemd/system/network@.service
echo "Type=oneshot" >> /etc/systemd/system/network@.service
echo "RemainAfterExit=yes" >> /etc/systemd/system/network@.service
echo "EnvironmentFile=/etc/conf.d/network@%i" >> /etc/systemd/system/network@.service
echo " " >> /etc/systemd/system/network@.service
echo "ExecStart=/usr/bin/ip link set dev %i up" >> /etc/systemd/system/network@.service
echo "ExecStart=/usr/bin/ip addr add ${address}/${netmask} broadcast ${broadcast} dev %i" >> /etc/systemd/system/network@.service
echo "ExecStart=/usr/bin/sh -c 'test -n ${gateway} && /usr/bin/ip route add default via ${gateway}'" >> /etc/systemd/system/network@.service
echo " " >> /etc/systemd/system/network@.service
echo "ExecStop=/usr/bin/ip addr flush dev %i" >> /etc/systemd/system/network@.service
echo "ExecStop=/usr/bin/ip link set dev %i down" >> /etc/systemd/system/network@.service
echo " " >> /etc/systemd/system/network@.service
echo "[Install]" >> /etc/systemd/system/network@.service
echo "WantedBy=multi-user.target" >> /etc/systemd/system/network@.service

systemctl enable network@EXT0.service
systemctl start network@EXT0.service

echo -e "${COLOR2}INT0 Setup Completed${NC}"

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
echo -e "${COLOR1}Microcode/grub/dnsutils/open-vm-tools/vim/v2ray/screen${NC}"
pacman -Sy intel-ucode grub dnsutils open-vm-tools vim v2ray screen wget
echo -e "${COLOR2}Completed${NC}"

#install Bootloader
echo -e "${COLOR1}Install grub Boot Loader into /dev/sda1${NC}"
grub-install --target=i386-pc /dev/sda1
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "${COLOR2}Completed${NC}"

#Finished install
sync
sync
sync
exit
